FROM litespeedtech/openlitespeed:latest
COPY wp-install.sh /

LABEL version="0.0.1"
LABEL description="WordPress com Litespeed"
LABEL maintainer="Alan Mosko<falecom@alanmosko.com.br>"

ENV VIRTUAL_HOST="domain.com"
ENV WORDPRESS_DB_NAME="wordpress"
ENV WORDPRESS_DB_USER="root"
ENV WORDPRESS_DB_PASS=""
ENV WORDPRESS_DB_HOST="localhost"
ENV WORDPRESS_DB_PORT="3306"
ENV WP_LOCALE="pt_BR"
ENV WORDPRESS_AD_USER="AdminUser"
ENV WORDPRESS_AD_PASS="AdminPass"
ENV WORDPRESS_AD_MAIL="admin@email.com"

RUN apt-get update -y
RUN apt-get upgrade -y
RUN apt-get install -y wget cron nano zip unzip curl git
RUN wget -O - http://rpms.litespeedtech.com/debian/enable_lst_debain_repo.sh | bash
RUN apt-get install -y lsphp74-ldap
RUN apt-get clean
RUN apt-get autoclean
RUN apt-get autoremove --purge -y wget
RUN rm -rf /var/lib/apt/lists/*

ENV PATH="${PATH}:/usr/local/lsws/lsphp74/bin/"

WORKDIR /var/www/vhosts/localhost/html

RUN ./wp-install.sh
