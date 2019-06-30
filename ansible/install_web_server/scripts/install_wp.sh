#!/bin/bash

DOMAIN=example.org
USER=example

DBHOST=localhost
DBNAME=example
DBUSER=example
DBPASS="password"

ADMIN_EMAIL="admin@${DOMAIN}"
ADMIN_USER="${USER}_admin"
ADMIN_PASSWORD=`apg -M SNCL -m 14 -x 14 -n 1`

if [ -e /etc/redhat-release ]
then
        GROUP=nginx
else
        GROUP=www-data
fi

/usr/local/bin/wp core download --path=/home/${USER}/www --locale=ru_RU --force

/usr/local/bin/wp config create --path=/home/${USER}/www --dbhost=${DBHOST} --dbname=${DBNAME} --dbuser=${DBUSER} --dbpass=${DBPASS}

/usr/local/bin/wp core install --path=/home/${USER}/www --url=https://${DOMAIN} --title=${DOMAIN} --admin_user=${ADMIN_USER} --admin_password="${ADMIN_PASSWORD}" --admin_email="${ADMIN_EMAIL}"

chown -R ${USER}:${GROUP} /home/${USER}/www
chmod -R a+r /home/${USER}/www
find /home/${USER}/www -type d -exec chmod a+x {} \;

echo "admin email: ${ADMIN_EMAIL}"
echo "admin user: ${ADMIN_USER}"
echo "admin password: ${ADMIN_PASSWORD}"
