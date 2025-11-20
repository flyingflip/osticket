# FlyingFlip Studios, LLC. Platform Docker Container
### Michael R. Bagnall: <mbagnall@flyingflip.com>

This container is a standard Linux, Apache and PHP container designed to work with a separate database container for the purposes of running enterprise, production web sites or for developing web sites on your local computer. It is compiled to support Intel/AMD64 and Apple Silicon processors.

The best way to configure the container is through a `docker-compose.yml` document where volumes and environmental varaibles can be easily laid out and documented. Using environment variables, you can specify the version of PHP you wish to use as well as many configuration options for PHP and Apache. You can also use the optional `.mounts` file to define symlink mountpoints as part of your deployment to NAS or other external file hosting services as a way to keep assets in their own location and easily referenceable by all containers in your cluster.

### Example docker-compose.yml file
```yaml
services:
  webapp:
    image: flyingflip/linux
    container_name: webapp
     # Volumes specify where our files are within the container. In this example, the directory where
     # the docker-compose.yml is located happens to also be the folder where the web document root folder is.
     # As such, we will mount it to a common http endpoint at /var/www/html and tell Apache via our 
     # environment variables where to look for our web folder.
    volumes:
      - ./:/var/www/html
    environment:
      # We need to tell Apache where to find the document root. Based on the volumnes configuration, it is
      # in a folder called "web" in the current directory. If it were in one called "docroot" it would be
      # listed as /var/www/html/docroot
      DOCROOT: /var/www/html/web 
      # Specify the version of PHP we wish to use. Available options are PHP 7.4, 8.0, 8.1, 8.2 and 8.3
      PHP_VERSION: php8.3
      # Other environment variable settings detailed below can go in this space as well.
    ports:
      # Always map port 80 and 443. If you use nginx for your proxy, proxy to port 443 using https. The container
      # contains the self signed certs to make secure communication happen on the intranet level, giving you end
      # to end encryption on all of your network traffic.
      - "8097:80"
      - "8098:443"
    depends_on:
      - datastore
    networks:
      - webnetwork
    restart: unless-stopped

  datastore:
    image: mariadb:10.6
    container_name: datastore
    environment:
      MYSQL_USER: user
      MYSQL_PASSWORD: mypassword
      MYSQL_DATABASE: drupal
      MYSQL_ROOT_PASSWORD: mypassword
      MYSQL_ALLOW_EMPTY_PASSWORD: 'no'
    expose:
      - "3306"
    volumes:
      - ./mysql:/var/lib/mysql
    networks:
      webnetwork:
        aliases:
          - db
    restart: unless-stopped

networks:
  webnetwork:
```

## Additional Environment Variables

**HSTS_HEADER**  
_Default Value: NULL_  
Set to 1 (or any value) if you want to put HSTS headers in your Apache headers. Do not configure this item or set to 0 to disable.

**HSTS_PRELOAD**  
_Default Value: 0_  
Dictates whether the HSTS header should be preloadable. PLEASE USE WITH CAUTION [HTTPS Preloading](https://hstspreload.org). Set to 1 if you want to put HSTS headers in your confiuguration or 0 if you do not (if unset, zero is assumed).

**HSTS_TTL**  
_Default Value: 3600_  
The TTL for an HSTS configured header (1 Hour by default).  

**HTACCESS_DESCRIPTION**  
THe web site description to appear in the htaccess username/password box. This is what determines if this option is enabled. A value here enables the htaccess authentication system in Apache. Omission leaves it disabled.

**HTACCESS_PASSWORD**  
The password for the user configured in the htaccess dialog.

**HTACCESS_USERNAME**  
The username to be configured in the htaccess dialog.  

**PHP_DISPLAY_ERRORS**  
_Default Value: Off_  
This directive controls whether or not and where PHP will output errors, notices and warnings.

**PHP_DISPLAY_STARTUP_ERRORS**  
_Default Value: Off_  
The display of errors which occur during PHP's startup sequence are handled separately from display_errors.

**PHP_MAX_EXECUTION_TIME**  
_Default Value: 300_  
Maximum execution time of each script, in seconds. A value of 0 disables the limit.

**PHP_MAX_INPUT_TIME**  
_Default Value: 300_  
Maximum amount of time each script may spend parsing request data. A value of -1 disables the limit.

**PHP_MAX_INPUT_VARS**  
_Default Value: 1000_  
How many GET/POST/COOKIE input variables may be accepted.

**PHP_MEMORY_LIMIT**  
_Default Value: 386M_  
Maximum amount of memory a script may consume.

**PHP_POST_MAX_SIZE**  
_Default Value: 256M_  
Maximum size of POST data that PHP will accept. A value of 0 disables the limit.

**PHP_UPLOAD_MAX_FILESIZE**  
_Default Value: 256M_  
Maximum allowed size for uploaded files.  

**XDEBUG**  
_Default Value: NULL_  
This is a boolean. Set to 1 to enable xdebug for this container. Set to 0 or leave as default to disable. This has a performance cost so choose wisely.  
