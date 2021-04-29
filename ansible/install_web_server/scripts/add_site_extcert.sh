#!/bin/bash

ORIGIFS=$IFS
ORIGOFS=$OFS

IFS=$(echo -en "\n\b")
OFS=$(echo -en "\n\b")

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
LOG="/var/log/scripts/add_site.log"

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

debug ""
debug "===================================="
DT=`date "+%Y-%m-%d_%H-%M"`
debug ${DT}
debug "start"

if [ -e /etc/redhat-release ]
then
    GROUP=nginx

    if [ -e /etc/php-fpm.d/ ]
    then
        FPM_PATH=/etc/php-fpm.d/
    else
	echo "Can't find FPM config path, please create /etc/php-fpm.d/"
	exit
    fi
else
    GROUP=www-data
    FPM_PATH=/etc/php/7.3/fpm/pool.d
fi

debug "group: ${GROUP}"
debug "fpm path: ${FPM_PATH}"
FPM_SERVICE=`systemctl list-unit-files | grep fpm | grep enabled | awk '{print $1}'`
debug "fpm service: ${FPM_SERVICE}"


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
    print_help
    exit 1
fi

debug "user name: "${USER_NAME}
debug "domain name: "${DOMAIN_NAME}
debug "ip: "${IP}

useradd -g ${GROUP} -m -s /bin/bash ${USER_NAME}

#user_password=`apg -M SNCL -m 14 -x 14 -n 1`
#user_password=`apg -M SNCL -m 14 -x 14 -n 1 -E "\&/\"=\\\`:'"`
user_password=`apg -M NL -a 1 -m 16 -x 16 -n 1`
debug "password: "${user_password}
echo "${USER_NAME}:${user_password}" | chpasswd

mkdir /home/${USER_NAME}/{www,logs,temp}
echo "<?php echo (\$_SERVER['HTTP_HOST']); ?>" > /home/${USER_NAME}/www/index.php
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

# Copy external certificate

mkdir /etc/nginx/ssl_external/${DOMAIN_NAME}
scp ${DOMAIN_NAME}:/etc/letsencrypt/live/${DOMAIN_NAME}/fullchain.pem /etc/nginx/ssl_external/${DOMAIN_NAME}/cert.pem
scp ${DOMAIN_NAME}:/etc/letsencrypt/live/${DOMAIN_NAME}/privkey.pem /etc/nginx/ssl_external/${DOMAIN_NAME}/key.pem

# Write nginx config

config_file="/etc/nginx/sites-available/${DOMAIN_NAME}.conf"
cp ${DIR}/conf_templates/nginx_template_ssl_external.conf ${config_file}
sed -i "s/##USER_NAME##/${USER_NAME}/g" $config_file
sed -i "s/##DOMAIN_NAME##/${DOMAIN_NAME}/g" $config_file
if [ "" != "${IP}" ]
then
	sed -i "s/##IP##/${IP}:/g" $config_file
fi
ln -s ${config_file} /etc/nginx/sites-enabled/${DOMAIN_NAME}.conf
systemctl restart nginx


# === MySQL ===

DB_NAME=${USER_NAME}
DB_USER=$(echo ${USER_NAME} | cut -c-16)
#DB_PASS=`apg -M SNCL -m 14 -x 14 -n 1`
#DB_PASS=`apg -M SNCL -m 14 -x 14 -n 1 -E "\&/\"=\\\`:'"`
DB_PASS=`apg -M NL -a 1 -m 16 -x 16 -n 1`
debug "MySQL password: "${DB_PASS}

echo "CREATE DATABASE \`${DB_NAME}\`; GRANT ALL ON \`${DB_NAME}\`.* TO '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}'" | mysql -u root

# === Summary ===

AUTH_FILE=/home/${USER_NAME}/auth.txt

echo "=== ${DOMAIN_NAME} ===" >> ${AUTH_FILE}
echo '' >> ${AUTH_FILE}
echo '=== SSH ===' >> ${AUTH_FILE}
echo "host: "${DOMAIN_NAME} >> ${AUTH_FILE}
echo "user: "${USER_NAME} >> ${AUTH_FILE}
echo "pass: "${user_password} >> ${AUTH_FILE}
echo '' >> ${AUTH_FILE}
echo "=== MySQL ===" >> ${AUTH_FILE}
echo "host: localhost" >> ${AUTH_FILE}
echo "base: "${DB_NAME} >> ${AUTH_FILE}
echo "user: "${DB_USER} >> ${AUTH_FILE}
echo "pass: "${DB_PASS} >> ${AUTH_FILE}


debug "end"
DT=`date "+%Y-%m-%d_%H-%M"`
debug ${DT}

IFS=$ORIGIFS
OFS=$ORIGOFS

