#!/bin/bash

ORIGIFS=$IFS
ORIGOFS=$OFS

IFS=$(echo -en "\n\b")
OFS=$(echo -en "\n\b")

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
LOG="/var/log/scripts/del_site.log"
DT=`date "+%Y-%m-%d_%H-%M"`

if [ ! -e /var/log/scripts ];
then
    mkdir -p /var/log/scripts
fi

function print_help()
{
  echo "Delete site (nginx, php-fpm configs, mysql db and user)"
  echo "Usage: `basename $0` username domainname"
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

if [ -e /etc/redhat-release ]
then
	FPM_PATH=/etc/opt/remi/php71/php-fpm.d
	FPM_SERVICE=php71-php-fpm
else
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

debug "user name: "${USER_NAME}
debug "domain name: "${DOMAIN_NAME}

if [ ! -e /home/backup/${USER_NAME}_${DT} ]
then
	mkdir /home/backup/${USER_NAME}_${DT}
fi

cd /home/
tar -cf ${USER_NAME}_files.tar /home/${USER_NAME}
mv /home/${USER_NAME}_files.tar /home/backup/${USER_NAME}_${DT}/
mysqldump -u root "${USER_NAME}" > /home/backup/${USER_NAME}_${DT}/${USER_NAME}_db.sql
bzip2 /home/backup/${USER_NAME}_${DT}/${USER_NAME}_db.sql

unlink /etc/nginx/sites-enabled/${DOMAIN_NAME}.conf
rm /etc/nginx/sites-available/${DOMAIN_NAME}.conf
systemctl restart nginx

rm ${FPM_PATH}/${DOMAIN_NAME}.conf
systemctl restart ${FPM_SERVICE}

userdel -r ${USER_NAME}

echo "DROP DATABASE IF EXISTS \`${USER_NAME}\`" | mysql -u root
echo "REVOKE ALL PRIVILEGES, GRANT OPTION FROM '${USER_NAME}'" | mysql -u root
echo "DROP USER '${USER_NAME}'" | mysql -u root
echo "REVOKE ALL PRIVILEGES, GRANT OPTION FROM '${USER_NAME}'@'localhost'" | mysql -u root
echo "DROP USER '${USER_NAME}'@'localhost'" | mysql -u root


debug "end"
debug ${DT}

IFS=$ORIGIFS
OFS=$ORIGOFS

