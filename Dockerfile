FROM codeblick/shopware-6:php-8.2

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

RUN export DEBIAN_FRONTEND=noninteractive && \
    wget https://repo.mysql.com/mysql-apt-config_0.8.24-1_all.deb && \
    apt install -y ./mysql-apt-config_*_all.deb && \
    rm ./mysql-apt-config_*_all.deb

RUN apt update

RUN echo "mysql-community-server mysql-community-server/root-pass password root" | debconf-set-selections
RUN echo "mysql-community-server mysql-community-server/re-root-pass password root" | debconf-set-selections
RUN echo "mysql-community-server mysql-server/default-auth-override select Use Legacy Authentication Method (Retain MySQL 5.x Compatibility)" | debconf-set-selections

RUN apt install -y \
    mysql-server \
    sudo \
    git

# RUN sed -Ei 's/bind-address.*/bind-address=0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
RUN echo "bind-address=0.0.0.0" >> /etc/mysql/mysql.conf.d/mysqld.cnf
RUN echo "log_bin_trust_function_creators=1" >> /etc/mysql/mysql.conf.d/mysqld.cnf

USER www-data

ARG COB_SW_VERSION
ENV SW_VERSION=${COB_SW_VERSION}

RUN cd /var/www/html && \
    composer create-project shopware/production:${SW_VERSION}-flex .

USER root

RUN mkdir /migrations

COPY ./scripts/setup-shopware.sh /usr/local/bin/setup-shopware
RUN chmod +x /usr/local/bin/setup-shopware

EXPOSE 3306
VOLUME /var/lib/mysql
VOLUME /var/www/html

CMD ["setup-shopware"]
