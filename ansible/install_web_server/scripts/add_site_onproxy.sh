#!/bin/bash

ORIGIFS=$IFS
ORIGOFS=$OFS

IFS=$(echo -en "\n\b")
OFS=$(echo -en "\n\b")

source $(dirname "$0")/common/func.sh

function print_help()
{
  echo "Add proxied site"
  echo "Usage: `basename $0` domain_name"
  echo "Params:"
  echo "  -h, --help - this help"
  echo "  -v, --verbose - verbose output (write not only to log but on terminal)"
  return 0
}

out_if_need_help

debug ""
debug "===================================="
DT=`date "+%Y-%m-%d_%H-%M"`
debug ${DT}
debug "start"

DOMAIN_NAME=$(set_param "${ARGS[1]}" "Error: no domain name given")

debug "domain name: ${DOMAIN_NAME}"
debug "=== upload SSH key ==="

/root/scripts/upload_ssh_key.sh ${VERBOSE_FLAG} ${DOMAIN_NAME}

if [ "0" != "$(echo $?)" ]
then
    echo "Connection error"
    exit 1
fi

debug "=== add site on proxy ==="

IP=$(ip -f inet address | grep inet | grep -v 127.0.0.1 | awk '{print $2}' | awk -F / '{print $1}'); echo "_${IP}_"
debug "IP: ${IP}"

cat /root/scripts/conf_templates/nginx_template_ssl_proxy.conf | sed "s/##PROXY_DESTINATION_IP##/${IP}/" > /tmp/nginx_template_ssl_proxy.conf
scp  -o StrictHostKeyChecking=no /tmp/nginx_template_ssl_proxy.conf ${DOMAIN_NAME}:/root/scripts/conf_templates/nginx_template_ssl_proxy.conf
rm /tmp/nginx_template_ssl_proxy.conf

scp  -o StrictHostKeyChecking=no /root/scripts/conf_templates/nginx_template_precert_proxy.conf ${DOMAIN_NAME}:/root/scripts/conf_templates/nginx_template_precert_proxy.conf
scp  -o StrictHostKeyChecking=no /root/scripts/add_site_proxy.sh ${DOMAIN_NAME}:/root/scripts/add_site_proxy.sh

ssh  -o StrictHostKeyChecking=no ${DOMAIN_NAME} "/root/scripts/add_site_proxy.sh  ${VERBOSE_FLAG} ${DOMAIN_NAME}"

USERNAME=$(echo "${DOMAIN_NAME}" | sed 's/\./_/ig')
debug "username: ${USERNAME}"

/root/scripts/add_site_extcert.sh ${VERBOSE_FLAG} ${USERNAME} ${DOMAIN_NAME} ${IP}

debug "end"
DT=`date "+%Y-%m-%d_%H-%M"`
debug ${DT}

cd /home/${USERNAME}/www
/root/scripts/mywpinstall.sh

#sendmessage "Finish add site ${DOMAIN_NAME} on proxy, next cmd: cd /home/${USERNAME}/www && /root/scripts/mywpinstall.sh"

IFS=$ORIGIFS
OFS=$ORIGOFS
