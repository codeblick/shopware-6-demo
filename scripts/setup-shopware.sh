#!/usr/bin/env bash
set -e

if [ -d /var/lib/mysql/${MYSQL_DATABASE} ] ; then
    echo "Shopware is already installed."
    
    mkdir -p /var/run/mysqld
    chown -R mysql /var/run/mysqld
    mysqld &

    wait-for-it ${MYSQL_HOST}:${MYSQL_PORT}
else
    mkdir -p /var/run/mysqld
    chown -R mysql /var/run/mysqld
    mysqld &

    wait-for-it ${MYSQL_HOST}:${MYSQL_PORT}

    mysql -u root -h localhost -e "
        CREATE DATABASE ${MYSQL_DATABASE};
        CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
        GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE} . * TO '${MYSQL_USER}'@'%';
        FLUSH PRIVILEGES;
    "

    cd /var/www/html

    sudo -u www-data -E bash -c "
        bin/console system:setup \
            --database-url=mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE} \
            --generate-jwt-keys \
            --app-env=${SW_ENV} \
            --app-url=${SW_URL} \
            --http-cache-enabled=${SW_CACHE} \
            --mailer-url=${SW_MAILER} \
            --no-interaction

        bin/console system:install --create-database --basic-setup --no-interaction

        bin/console store:download -p SwagPlatformDemoData
        bin/console plugin:install --activate SwagPlatformDemoData
    "
    
    if [ -n "$SKIP_DEMO" ]; then
        echo "Installing Demo was skipped!"
    else
        mysql -u root -h localhost -e "
            USE ${MYSQL_DATABASE};
            INSERT INTO system_config (id,configuration_key,configuration_value,sales_channel_id,created_at,updated_at) VALUES
	        (0x68832B34D0324BC7A17CA65DA4196900,'core.frw.completedAt','{\"_value\":\"2021-07-24T11:21:08+00:00\"}',NULL,'2021-07-24 11:21:08.054',NULL);
        "

        if [ -z "${COB_PLUGIN_NAME}" ]; then
            echo "No plugin was selected for installation."
        else
            sudo -u www-data -E bin/console plugin:install --activate ${COB_PLUGIN_NAME}
        fi
    
        if [ -z "${COB_APP_NAME}" ]; then
            echo "No app was selected for installation."
        else
            sudo -u www-data -E bin/console app:install --force --activate ${COB_APP_NAME}
        fi
    fi

    for i in `/bin/ls -1 /migrations/*.sql`; do
        mysql -u root -h localhost ${MYSQL_DATABASE} < ${i}
    done
    
    sudo -u www-data -E bin/console cache:clear
fi

/usr/sbin/apache2ctl -DFOREGROUND
