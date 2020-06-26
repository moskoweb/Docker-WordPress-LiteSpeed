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

    if [ -n "$WORDPRESS_PLUGINS" ]; then
        echo "WordPress | Plugins Install"
        wp plugin install --allow-root $WORDPRESS_PLUGINS
    fi

    if [ -n "$WORDPRESS_ACTIVEP" ]; then
        echo "WordPress | Plugins Activate"
        wp plugin activate --allow-root $WORDPRESS_ACTIVEP
    fi

    echo "WordPress | Plugin Activate"
    wp plugin activate --allow-root litespeed-cache

    echo "WordPress | Plugin Remove"
    wp plugin delete --allow-root akismet hello

    echo "WordPress | Theme Update"
    wp theme update --allow-root --all

    echo "WordPress | Comment Delete"
    wp comment delete 1 --force --allow-root

    echo "WordPress | Post and Pages Delete"
    wp post delete 1 --force --allow-root
    wp post delete 2 --force --allow-root
    wp post delete 3 --force --allow-root

    echo "WordPress | FTP Set"
    wp config set FS_METHOD direct --allow-root

    echo "WordPress | Cron Set"
    wp config set DISABLE_WP_CRON true --allow-root
    crontab -l > mtccron
    echo "# WordPress Cron" >> mtccron
    echo "*/15 * * * * lsadm php -q /var/www/vhosts/localhost/html/wp-cron.php" >> mtccron
    crontab mtccron
    rm mtccron

fi

chown -R lsadm:lsadm /var/www/vhosts/localhost/html/.*

chmod -R g+rw /var/www/vhosts/localhost/html/.*

chown -R lsadm:lsadm /var/www/vhosts/localhost/html/*

chmod -R g+rw /var/www/vhosts/localhost/html/*

echo "PHP | Ini Set Values"
sed -i "s/upload_max_filesize = 2M/upload_max_filesize = $PHP_INI_MAXFILE_SIZE/g" /usr/local/lsws/lsphp74/etc/php/7.4/litespeed/php.ini
sed -i "s/post_max_size = 8M/post_max_size = $PHP_INI_MAXFILE_SIZE/g" /usr/local/lsws/lsphp74/etc/php/7.4/litespeed/php.ini
sed -i "s/max_execution_time = 30/max_execution_time = $PHP_INI_EXECUTION_TIME/g" /usr/local/lsws/lsphp74/etc/php/7.4/litespeed/php.ini
sed -i "s/max_input_time = 60/max_input_time = $PHP_INI_EXECUTION_TIME/g" /usr/local/lsws/lsphp74/etc/php/7.4/litespeed/php.ini
sed -i "s/memory_limit = 128M/memory_limit = $PHP_INI_MEMORY_LIMIT/g" /usr/local/lsws/lsphp74/etc/php/7.4/litespeed/php.ini
sed -i "s/;max_input_vars = 1000/max_input_vars = 3000/g" /usr/local/lsws/lsphp74/etc/php/7.4/litespeed/php.ini

/usr/local/lsws/bin/lswsctrl restart

echo "WordPress | Install Completed"
