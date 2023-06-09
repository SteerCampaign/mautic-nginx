# Catch-all server block, resulting in a 444 response for unknown domains.
server {
	# Ports to listen on
	listen 80 default_server;
	listen [::]:80 default_server;

	# Server name to listen for
	server_name _;


	# Path to document root
	root /sites/singlesite.com/public;

	# File to be used as index
	index index.php;

	# Overrides logs defined in nginx.conf, allows per site logs.
	access_log /sites/singlesite.com/logs/access.log;
	error_log /sites/singlesite.com/logs/error.log;

	# Default server block rules
	include global/server/defaults.conf;

	location / {
		try_files $uri $uri/ /index.php?$args;
	}

	location ~ \.php$ {
		try_files $uri =404;
		include global/fastcgi-params.conf;

		# Change socket if using PHP pools or different PHP version
        fastcgi_pass unix:/run/php/php8.0-fpm.sock;
	}

    # Rewrite robots.txt
    rewrite ^/robots.txt$ /index.php last;

    return 444;
}
