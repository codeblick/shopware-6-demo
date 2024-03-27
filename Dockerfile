ARG PHP_VERSION

FROM codeblick/shopware-6-demo-base:php-$PHP_VERSION

USER www-data

ARG SW_VERSION

RUN cd /var/www/html && \
    composer create-project shopware/production . $SW_VERSION --no-scripts

USER root
