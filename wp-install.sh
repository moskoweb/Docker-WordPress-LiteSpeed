#!/bin/bash

echo "MySQL | Create database"
mysql --no-defaults -h $WORDPRESS_DB_HOST --port $WORDPRESS_DB_PORT -u $WORDPRESS_DB_USER -p$WORDPRESS_DB_PASS -e "CREATE DATABASE IF NOT EXISTS $WORDPRESS_DB_NAME;"

cd /var/www/vhosts/localhost/html

if [ ! -e wp-config.php ]; then

    echo "WordPress | Core Download"
    wp core download --locale=$WP_LOCALE --allow-root

    echo "WordPress | Core Configuration"
    wp core config --allow-root \
    --dbname=$WORDPRESS_DB_NAME \
    --dbuser=$WORDPRESS_DB_USER \
    --dbpass=$WORDPRESS_DB_PASS \
    --dbhost="$WORDPRESS_DB_HOST:$WORDPRESS_DB_PORT"

    echo "WordPress | Config Salts"
    wp config shuffle-salts --allow-root

    if ! $(wp core is-installed --allow-root); then

        echo "WordPress | Core Install"
        wp core install --url=$VIRTUAL_HOST \
        --title="WordPress com Litespeed" \
        --admin_user=$WORDPRESS_AD_USER \
        --admin_password=$WORDPRESS_AD_PASS \
        --admin_email=$WORDPRESS_AD_MAIL \
        --skip-email --allow-root

    fi

    echo "WordPress | Rewrite Set"
    wp rewrite structure '/%postname%/' --allow-root

    echo "WordPress | Plugin Install"
    wp plugin install --allow-root litespeed-cache

    echo "WordPress | Plugin Activate"
    wp plugin activate --allow-root litespeed-cache

    echo "WordPress | Plugin Remove"
    wp plugin delete --allow-root akismet hello-dolly

fi
