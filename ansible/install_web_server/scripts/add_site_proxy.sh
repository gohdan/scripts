#!/bin/bash

ORIGIFS=$IFS
ORIGOFS=$OFS

IFS=$(echo -en "\n\b")
OFS=$(echo -en "\n\b")

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
LOG="/var/log/scripts/add_site_proxy.log"

if [ ! -e /var/log/scripts ];
then
    mkdir -p /var/log/scripts
fi

function print_help()
{
  echo "Add site proxy (nginx config and LE certificate)"
  echo "Usage: `basename $0` domainname"
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

debug ""
debug "===================================="
DT=`date "+%Y-%m-%d_%H-%M"`
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
    DOMAIN_NAME="${ARGS[1]}"
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

debug "domain name: "${DOMAIN_NAME}

if [ ! -f /usr/bin/host ]
then
    if [ -f /etc/redhat-release ]
    then
        yum makecache
        yum install -y bind-utils
    elif [ -f /etc/lsb-release ]
    then
        apt update
        apt install -y host
    else
        echo "can't determine IP"
        exit 1
    fi
fi

IP=$(host ${DOMAIN_NAME} | awk -F "has address " '{print $2}')
debug "IP: ${IP}"

# Write nginx simple config

config_file="/etc/nginx/sites-available/${DOMAIN_NAME}.conf"

cp ${DIR}/conf_templates/nginx_template_precert_proxy.conf ${config_file}
sed -i "s/##DOMAIN_NAME##/${DOMAIN_NAME}/g" $config_file
if [ "" != "${IP}" ]
then
	sed -i "s/##IP##/${IP}:/g" $config_file
fi

ln -s ${config_file} /etc/nginx/sites-enabled/${DOMAIN_NAME}.conf
systemctl restart nginx

# Obtain certificate

if [ ! -e /var/lib/nginx/tmp ]
then
	mkdir -p /var/lib/nginx/tmp
	chown -R nginx /var/lib/nginx/tmp
fi
certbot certonly -n --webroot -d ${DOMAIN_NAME} -d www.${DOMAIN_NAME} -w /var/lib/nginx/tmp

# Write nginx final config

cp ${DIR}/conf_templates/nginx_template_ssl_proxy.conf ${config_file}
sed -i "s/##DOMAIN_NAME##/${DOMAIN_NAME}/g" $config_file
if [ "" != "${IP}" ]
then
	sed -i "s/##IP##/${IP}:/g" $config_file
fi
systemctl restart nginx

debug "end"
DT=`date "+%Y-%m-%d_%H-%M"`
debug ${DT}

IFS=$ORIGIFS
OFS=$ORIGOFS

