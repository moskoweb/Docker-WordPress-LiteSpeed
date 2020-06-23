#!/bin/bash
set -euo pipefail

/usr/local/lsws/bin/openlitespeed -d

cd /var/www/vhosts/localhost/html

wp core download --locale=pt_BR --allow-root

wp core config --allow-root \
    --dbname=$WORDPRESS_DB_NAME \
    --dbuser=$WORDPRESS_DB_USER \
    --dbpass=$WORDPRESS_DB_PASS \
    --dbhost=$WORDPRESS_DB_HOST \
    --dbprefix=$WORDPRESS_TPREFIX

wp core install --allow-root \
    --url=$VIRTUAL_HOST \
    --title="WordPress com Litespeed" \
    --admin_user=$WORDPRESS_AD_USER \
    --admin_password=$WORDPRESS_AD_PASS \
    --admin_email=$WORDPRESS_AD_MAIL

wp plugin install --allow-root litespeed-cache

wp plugin activate --allow-root litespeed-cache
