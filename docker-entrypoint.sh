#!/bin/bash
set -euo pipefail

/usr/local/lsws/bin/openlitespeed -d

mysql --no-defaults -h $WORDPRESS_DB_HOST --port $WORDPRESS_DB_PORT -u $WORDPRESS_DB_USER -p$WORDPRESS_DB_PASS -e "CREATE DATABASE IF NOT EXISTS $WORDPRESS_DB_NAME;"

cd /var/www/vhosts/localhost/html

wp core download --locale=$WP_LOCALE --allow-root

wp config shuffle-salts

wp config set WP_SITEURL "https://$VIRTUAL_HOST" --add --type=constant --allow-root
wp config set WP_HOME "https://$VIRTUAL_HOST" --add --type=constant --allow-root
wp config set DB_NAME $WORDPRESS_DB_NAME --add --type=constant --allow-root
wp config set DB_USER $WORDPRESS_DB_USER --add --type=constant --allow-root
wp config set DB_PASSWORD $WORDPRESS_DB_PASS --add --type=constant --allow-root
wp config set DB_HOST "$WORDPRESS_DB_HOST:$WORDPRESS_DB_PORT" --add --type=constant --allow-root
wp config set DB_PORT $WORDPRESS_DB_PORT --raw --add --type=constant --allow-root

if ! $(wp core is-installed); then
    wp core install --url=$VIRTUAL_HOST \
      --title="WordPress com Litespeed" \
      --admin_user=$WORDPRESS_AD_USER \
      --admin_password=$WORDPRESS_AD_PASS \
      --admin_email=$WORDPRESS_AD_MAIL \
      --skip-email \
  else
  fi

wp rewrite structure '/%postname%/'

wp plugin install --allow-root litespeed-cache

wp plugin activate --allow-root litespeed-cache
