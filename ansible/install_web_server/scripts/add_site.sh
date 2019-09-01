#!/bin/bash

ORIGIFS=$IFS
ORIGOFS=$OFS

IFS=$(echo -en "\n\b")
OFS=$(echo -en "\n\b")

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
LOG="/var/log/scripts/add_site.log"
DT=`date "+%Y-%m-%d_%H-%M"`

if [ ! -e /var/log/scripts ];
then
    mkdir -p /var/log/scripts
fi

function print_help()
{
  echo "Add site (nginx, php-fpm configs, mysql db and user)"
  echo "Usage: `basename $0` username domainname ip"
  echo "Params:"
  echo "  -h, --help - this help"
  echo "  -v, --verbose - verbose output (write not only to log but on terminal)"
  return 0
}

function debug
{
    if [ $# -eq 0 ]
    then
        echo ''
    else
        echo $1 >> ${LOG}
        if [ "1" == ${IF_VERBOSE} ]
        then
            echo $1
        fi
    fi
    return 0
}

if [ ! -n "${1}" ]
then
    print_help
    exit 1
fi

IF_VERBOSE=0
IF_HELP=0
IF_STOP=0
USER_NAME=""
DOMAIN_NAME=""
IP=""

if [ -e /etc/redhat-release ]
then
    GROUP=nginx

    if [ -e /etc/opt/remi/php71/php-fpm.d ]
    then
        FPM_PATH=/etc/opt/remi/php71/php-fpm.d
        FPM_SERVICE=php7.1-fpm
    else
        FPM_PATH=/etc/php-fpm.d/
        FPM_SERVICE=php-fpm
    fi
else
    GROUP=www-data
    FPM_PATH=/etc/php/7.1/fpm/pool.d
    FPM_SERVICE=php7.1-fpm
fi

debug ""
debug "===================================="
debug ${DT}
debug "start"

count=1
while [ -n "${1}" ]
do
    case "${1}" in
    -v | --verbose ) IF_VERBOSE=1 ;;
    -h | --help ) IF_HELP=1 ;;
    *) ARGS[${count}]=${1}
	count=$[ $count + 1 ];;
    esac
    shift
done

if [ "" != "${ARGS[1]}" ]
then
    USER_NAME="${ARGS[1]}"
fi

if [ "" != "${ARGS[2]}" ]
then
    DOMAIN_NAME="${ARGS[2]}"
fi

if [ "" != "${ARGS[3]}" ]
then
    IP="${ARGS[3]}"
fi

if [ "1" == ${IF_HELP} ]
then
    print_help
    exit 1
fi

if [ "" == "${USER_NAME}" ]
then
    debug "Error: no user name given"
    print_help
    exit 1
fi

if [ "" == "${DOMAIN_NAME}" ]
then
    debug "Error: no domain name given"
    print_help
    exit 1
fi

if [ "" == "${IP}" ]
then
    debug "Error: no IP given"
fi

debug "user name: "${USER_NAME}
debug "domain name: "${DOMAIN_NAME}
debug "ip: "${IP}

useradd -g ${GROUP} -m -s /bin/bash ${USER_NAME}

user_password=`apg -M SNCL -m 14 -x 14 -n 1`
debug "password: "${user_password}
echo "${USER_NAME}:${user_password}" | chpasswd

mkdir /home/${USER_NAME}/{www,logs,temp}
echo "<?php echo (\$_SERVER['HTTP_HOST']); phpinfo(); ?>" > /home/${USER_NAME}/www/index.php
chown -R ${USER_NAME}:${GROUP} /home/${USER_NAME}/
chmod -R a+r /home/${USER_NAME}/
find /home/${USER_NAME}/ -type d -exec chmod a+x {} \;

# Write php-fpm config

config_file="${FPM_PATH}/${DOMAIN_NAME}.conf"
cp ${DIR}/conf_templates/fpm.conf ${config_file}
sed -i "s/##USER_NAME##/${USER_NAME}/g" $config_file
sed -i "s/##GROUP##/${GROUP}/g" $config_file
sed -i "s/##DOMAIN_NAME##/${DOMAIN_NAME}/g" $config_file
systemctl restart ${FPM_SERVICE}

# Write nginx simple config

config_file="/etc/nginx/sites-available/${DOMAIN_NAME}.conf"

cp ${DIR}/conf_templates/nginx_template_precert.conf ${config_file}
sed -i "s/##USER_NAME##/${USER_NAME}/g" $config_file
sed -i "s/##DOMAIN_NAME##/${DOMAIN_NAME}/g" $config_file
if [ "" != "${IP}" ]
then
	sed -i "s/##IP##/${IP}:/g" $config_file
fi

ln -s ${config_file} /etc/nginx/sites-enabled/${DOMAIN_NAME}.conf
systemctl restart nginx

# Obtain certificate

certbot certonly -n --webroot -d ${DOMAIN_NAME} -d www.${DOMAIN_NAME} -w /home/${USER_NAME}/www

# Write nginx final config

cp ${DIR}/conf_templates/nginx_template_ssl.conf ${config_file}
sed -i "s/##USER_NAME##/${USER_NAME}/g" $config_file
sed -i "s/##DOMAIN_NAME##/${DOMAIN_NAME}/g" $config_file
if [ "" != "${IP}" ]
then
	sed -i "s/##IP##/${IP}:/g" $config_file
fi
systemctl restart nginx


# === MySQL ===

mysqlpasswd=`apg -M SNCL -m 14 -x 14 -n 1`
debug "MySQL password: "$mysqlpasswd
echo "CREATE DATABASE \`${USER_NAME}\`; GRANT ALL ON \`${USER_NAME}\`.* TO '${USER_NAME}'@'localhost' IDENTIFIED BY '${mysqlpasswd}'" | mysql -u root

# === Summary ===

echo ''
echo "=== ${DOMAIN_NAME} ==="
echo ''
echo '=== SSH ==='
echo "host: "${DOMAIN_NAME}
echo "user: "${USER_NAME}
echo "pass: "${user_password}
echo ''
echo "=== MySQL ==="
echo "host: localhost"
echo "base: "${USER_NAME}
echo "user: "${USER_NAME}
echo "pass: "$mysqlpasswd
echo ''


debug "end"
debug ${DT}

IFS=$ORIGIFS
OFS=$ORIGOFS

