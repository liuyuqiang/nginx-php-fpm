#!/bin/bash
#setting system
cp /usr/share/zoneinfo/UTC /etc/localtime
echo "UTC" > /etc/TZ

#nginx setting
chown -Rf nginx:nginx /data/project/www/

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

# Start supervisord and services
mkdir -p /data/project/supervisor/conf.d/
exec /usr/bin/supervisord -n -c /etc/supervisord.conf

