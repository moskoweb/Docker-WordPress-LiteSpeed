FROM litespeedtech/openlitespeed:latest
COPY docker-entrypoint.sh /usr/local/bin/

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
ENV WORDPRESS_AD_USER="Admin User"
ENV WORDPRESS_AD_PASS="Admin Pass"
ENV WORDPRESS_AD_MAIL="admin@domain.com"

RUN apt-get update && \
	apt-get install -y wget cron nano zip unzip curl git && \
	wget -O - http://rpms.litespeedtech.com/debian/enable_lst_debain_repo.sh | bash && \
	apt-get install -y lsphp74-ldap && \
	apt-get clean && \
	apt-get autoclean && \
	apt-get autoremove --purge -y wget && \
	rm -rf /var/lib/apt/lists/* && \
	chmod a+x /usr/local/bin/docker-*.sh

ENV PATH="${PATH}:/usr/local/lsws/lsphp74/bin/"

WORKDIR /var/www/vhosts/localhost/html

ENTRYPOINT ["docker-entrypoint.sh"]
