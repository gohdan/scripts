#!/bin/bash

ORIGIFS=$IFS
ORIGOFS=$OFS

IFS=$(echo -en "\n\b")
OFS=$(echo -en "\n\b")

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
LOG="/var/log/scripts/install_wp.log"
DT=`date "+%Y-%m-%d_%H-%M"`

if [ ! -e /var/log/scripts ];
then
    mkdir -p /var/log/scripts
fi

function print_help()
{
  echo "Install wordpress to site"
  echo "Usage: `basename $0` domain user dbhost dbname dbuser dbpass"
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
DOMAIN_NAME=""
USER_NAME=""
DBHOST=""
DBNAME=""
DBUSER=""
DBPASS=""

debug ""
debug "===================================="
debug ${DT}
debug "start"

count=6
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
    DOMAIN_NAME="${ARGS[1]}"
fi

if [ "" != "${ARGS[2]}" ]
then
    USER_NAME="${ARGS[2]}"
fi

if [ "" != "${ARGS[3]}" ]
then
    DBHOST="${ARGS[3]}"
fi

if [ "" != "${ARGS[4]}" ]
then
    DBUSER="${ARGS[4]}"
fi

if [ "" != "${ARGS[5]}" ]
then
    DBNAME="${ARGS[5]}"
fi

if [ "" != "${ARGS[6]}" ]
then
    DBPASS="${ARGS[6]}"
fi

if [ "1" == ${IF_HELP} ]
then
    print_help
    exit 1
fi

if [ "" == "${DOMAIN_NAME}" ]
then
    debug "Error: no domain name given"
    print_help
    exit 1
fi

if [ "" == "${USER_NAME}" ]
then
    debug "Error: no user name given"
    print_help
    exit 1
fi

if [ "" == "${DBHOST}" ]
then
    debug "Error: no dbhost given"
fi

if [ "" == "${DBNAME}" ]
then
    debug "Error: no dbname given"
fi

if [ "" == "${DBUSER}" ]
then
    debug "Error: no dbuser given"
fi

if [ "" == "${DBPASS}" ]
then
    debug "Error: no dbpass given"
fi

debug "domain name: "${DOMAIN_NAME}
debug "user name: "${USER_NAME}
debug "dbhost: "${DBHOST}
debug "dbname: "${DBNAME}
debug "dbuser: "${DBUSER}
debug "dbpass: "${DBPASS}

ADMIN_EMAIL="admin@${DOMAIN}"
ADMIN_USER="${USER}_admin"
ADMIN_PASSWORD=`apg -M SNCL -m 14 -x 14 -n 1 -E \&\\\/\"`

if [ -e /etc/redhat-release ]
then
        GROUP=nginx
else
        GROUP=www-data
fi

if [ ! -e /usr/local/bin/wp ]
then
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
    chmod a+rx /usr/local/bin/wp
fi


sudo -u ${USER} -i -- /usr/local/bin/wp core download --path=/home/${USER}/www --locale=ru_RU --force

sudo -u ${USER} -i -- /usr/local/bin/wp config create --path=/home/${USER}/www --dbhost=${DBHOST} --dbname=${DBNAME} --dbuser=${DBUSER} --dbpass=${DBPASS}

sudo -u ${USER} -i -- /usr/local/bin/wp core install --path=/home/${USER}/www --url=https://${DOMAIN} --title=${DOMAIN} --admin_user=${ADMIN_USER} --admin_password="${ADMIN_PASSWORD}" --admin_email="${ADMIN_EMAIL}"

chown -R ${USER}:${GROUP} /home/${USER}/www
chmod -R a+r /home/${USER}/www
find /home/${USER}/www -type d -exec chmod a+x {} \;

echo "admin email: ${ADMIN_EMAIL}"
echo "admin user: ${ADMIN_USER}"
echo "admin password: ${ADMIN_PASSWORD}"

debug "end"
debug ${DT}

IFS=$ORIGIFS
OFS=$ORIGOFS

