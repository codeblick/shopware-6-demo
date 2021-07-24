[![Docker Pulls](https://img.shields.io/docker/pulls/codeblick/shopware-6-demo.svg)](https://hub.docker.com/r/codeblick/shopware-6-demo/)
[![Docker Stars](https://img.shields.io/docker/stars/codeblick/shopware-6-demo.svg)](https://hub.docker.com/r/codeblick/shopware-6-demo/)

# codeblick/shopware-6-demo

This image is based on the codeblick/shopware-6:php-8.0 image.

## Supported tags

- v6.4.2.1

## Environment variables

```dockerfile
ENV MYSQL_USER=shopware
ENV MYSQL_PASSWORD=7Iuagg3or7O4
ENV MYSQL_DATABASE=shopware

ENV SW_ENV=dev
ENV SW_URL=http://localhost
ENV SW_CACHE=0
ENV SW_MAILER=smtp://mailhog:1025

ENV COB_PLUGIN_NAME=
ENV COB_APP_NAME=
```

## Example usage

```yaml
version: "3"
services:
  shopware:
    image: codeblick/shopware-6-demo:v6.4.2.1
    environment:
      - COB_PLUGIN_NAME=CobExample
      - COB_APP_NAME=CobExampleApp
    volumes:
      - ./src/CobExample:/var/www/html/custom/plugins/CobExample
      - ./src/CobExamplApp:/var/www/html/custom/apps/CobExampleApp
      - ./src/migrations:/migrations
    ports:
      - 80:80
      - 3000:3000
      - 3306:3306
      - 9998:9998
      - 9999:9999
```
