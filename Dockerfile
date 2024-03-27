ARG PHP_VERSION

FROM codeblick/shopware-6-demo-base:php-$PHP_VERSION

USER www-data

ARG SW_VERSION

RUN cd /var/www/html && \
    composer create-project --no-install shopware/production . $SW_VERSION; \
    jq '."minimum-stability" = "RC"' composer.json > composer.json.tmp; \
    mv composer.json.tmp composer.json; \
    composer install --no-scripts --no-interaction

USER root
