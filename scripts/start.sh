#!/bin/bash
#setting system
cp /usr/share/zoneinfo/UTC /etc/localtime
echo "UTC" > /etc/TZ

#nginx setting
chown -Rf nginx.nginx /data/project/www/

#php setting
sed -i '/php_flag\[display_errors\]/ d' /usr/local/etc/php-fpm.conf
sed -i "s/expose_php = On/expose_php = Off/g" /usr/local/etc/php/php.ini
sed -i "s/display_errors = On/display_errors = Off/g" /usr/local/etc/php/php.ini
sed -i "s/expose_php = On/expose_php = Off/g" /usr/local/etc/php/php.ini

sed -i "s/expose_php = On/expose_php = Off/g" /usr/local/etc/php/conf.d/docker-vars.ini
echo date.timezone=$(cat /etc/TZ) >> /usr/local/etc/php/conf.d/docker-vars.ini
echo "display_errors = Off" >> /usr/local/etc/php/conf.d/docker-vars.ini
echo "log_errors = On" >> /usr/local/etc/php/conf.d/docker-vars.ini
echo "error_log = /dev/stderr" >> /usr/local/etc/php/conf.d/docker-vars.ini

# Enable xdebug
XdebugFile='/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini'
if [[ "$ENABLE_XDEBUG" == "1" ]] ; then
  if [ -f $XdebugFile ]; then
  	echo "Xdebug enabled"
  else
  	echo "Enabling xdebug"
  	echo "If you get this error, you can safely ignore it: /usr/local/bin/docker-php-ext-enable: line 83: nm: not found"
  	# see https://github.com/docker-library/php/pull/420
    docker-php-ext-enable xdebug
    # see if file exists
    if [ -f $XdebugFile ]; then
        # See if file contains xdebug text.
        if grep -q xdebug.remote_enable "$XdebugFile"; then
            echo "Xdebug already enabled... skipping"
        else
            echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > $XdebugFile # Note, single arrow to overwrite file.
            echo "xdebug.remote_enable=1 "  >> $XdebugFile
            echo "remote_host=host.docker.internal" >> $XdebugFile
            echo "xdebug.remote_log=/tmp/xdebug.log"  >> $XdebugFile
            echo "xdebug.remote_autostart=false "  >> $XdebugFile # I use the xdebug chrome extension instead of using autostart
            # NOTE: xdebug.remote_host is not needed here if you set an environment variable in docker-compose like so `- XDEBUG_CONFIG=remote_host=192.168.111.27`.
            #       you also need to set an env var `- PHP_IDE_CONFIG=serverName=docker`
        fi
    fi
  fi
else 
    if [ -f $XdebugFile ]; then
        echo "Disabling Xdebug"
      rm $XdebugFile
    fi
fi

# Start supervisord and services
exec /usr/bin/supervisord -n -c /etc/supervisord.conf

