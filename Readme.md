# codeblick/shopware-6-demo

Docker-Image, um schnell eine Shopware-Demo-Instanz zu starten.

## Schnellstart mit docker run

Eine bestimmte Shopware-Version starten:

```bash
docker run --rm -it \
  -p 80:80 \
  codeblick/shopware-6-demo:v6.7.8.1
```

Du kannst jeden verfuegbaren Shopware-Tag verwenden, zum Beispiel v6.6.10.5 oder v6.7.8.1.

Den neuesten veroeffentlichten Build starten:

```bash
docker run --rm -it \
  -p 80:80 \
  codeblick/shopware-6-demo
```

## Tags und Updates

Neue Tags werden automatisch aus den neuesten Shopware-Releases gebaut.
Das Image aktualisiert dabei auch den standardmaessigen latest-Tag.

## Umgebungsvariablen

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

Wenn die entsprechenden Verzeichnisse vorhanden sind, werden `COB_PLUGIN_NAME` und `COB_APP_NAME` beim Start automatisch installiert.

## Beispielverwendung

```yaml
version: "3"
services:
  shopware:
    image: codeblick/shopware-6-demo:v6.7.8.1
    environment:
      - COB_PLUGIN_NAME=CobExample
      - COB_APP_NAME=CobExampleApp
    volumes:
      - ./src/CobExample:/var/www/html/custom/plugins/CobExample
      - ./src/CobExamplEApp:/var/www/html/custom/apps/CobExampleApp
      - ./src/migrations:/migrations
    ports:
      - 80:80
      - 3000:3000
      - 3306:3306
      - 9998:9998
      - 9999:9999
```
