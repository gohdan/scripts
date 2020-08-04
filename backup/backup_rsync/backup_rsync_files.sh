#!/bin/bash

ORIGIFS=$IFS
ORIGOFS=$OFS

IFS=$(echo -en "\n\b")
OFS=$(echo -en "\n\b")

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
LOG="/var/log/scripts/backup_rsync_files.log"

if [ ! -e /var/log/scripts ];
then
    mkdir -p /var/log/scripts
fi

function print_help()
{
  echo "Rsync www files from different servers "
  echo "Usage: `basename $0`"
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

#if [ ! -n "${1}" ]
#then
#    print_help
#    exit 1
#fi

IF_VERBOSE=0
IF_HELP=0
IF_STOP=0

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

SERVERS=(
example.org
)

for SERVER in ${SERVERS[*]}; do
    debug "server: ${SERVER}"
    DIRS=$(ssh ${SERVER} find /home/ -maxdepth 2 -type d -name www)
    for DIR in ${DIRS}
    do
        debug "dir: ${DIR}"
        mount /mnt/backup_${SERVER}

	DIR_LOCAL_FULL=/mnt/backup_${SERVER}/rsync${DIR}
	# remove /www from tail
	DIR_LOCAL=$(echo ${DIR_LOCAL_FULL} | sed 's@/www$@@' )
        debug "dir local: ${DIR_LOCAL}"

        if [ ! -e ${DIR_LOCAL} ];
        then
            mkdir -p ${DIR_LOCAL}
        fi

        #rsync --dry-run --bwlimit=1024 --delete -zavP ${SERVER}:${DIR} ${DIR_LOCAL}
        rsync --bwlimit=1024 --delete -zavP ${SERVER}:${DIR} ${DIR_LOCAL}
    done
done



debug "end"
DT=`date "+%Y-%m-%d_%H-%M"`
debug ${DT}

IFS=$ORIGIFS
OFS=$ORIGOFS


