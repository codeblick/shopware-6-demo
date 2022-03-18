FROM codeblick/shopware-6:php-8.1

ENV MYSQL_USER=shopware
ENV MYSQL_PASSWORD=7Iuagg3or7O4
ENV MYSQL_DATABASE=shopware
ENV MYSQL_HOST=127.0.0.1
ENV MYSQL_PORT=3306

ENV SW_ENV=dev
ENV SW_URL=http://localhost
ENV SW_CACHE=0
ENV SW_MAILER=smtp://mailhog:1025

USER root

COPY ./scripts/wait-for-it.sh /usr/local/bin/wait-for-it
RUN chmod +x /usr/local/bin/wait-for-it

RUN apt update
RUN apt install -y \
        mariadb-server \
        sudo \
        git
        
RUN sed -Ei 's/bind-address.*/bind-address=0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf

USER www-data

ARG COB_SW_VERSION
ENV SW_VERSION=${COB_SW_VERSION}

RUN cd /var/www/html && \
    git clone -b ${SW_VERSION} https://github.com/shopware/production.git . && \
    composer install --no-scripts --no-cache
    
USER root

RUN mkdir /migrations

COPY ./scripts/setup-shopware.sh /usr/local/bin/setup-shopware
RUN chmod +x /usr/local/bin/setup-shopware

EXPOSE 3306
VOLUME /var/lib/mysql
VOLUME /var/www/html

CMD ["setup-shopware"]
