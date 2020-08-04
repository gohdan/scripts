#!/bin/bash

ORIGIFS=$IFS
ORIGOFS=$OFS

IFS=$(echo -en "\n\b")
OFS=$(echo -en "\n\b")

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
LOG="/var/log/scripts/archive_files.log"

if [ ! -e /var/log/scripts ];
then
    mkdir -p /var/log/scripts
fi

function print_help()
{
  echo "Archive files from different places"
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

for i in $(ls /mnt); do
    main_dir=/mnt/${i}
    debug "main dir: ${main_dir}"
    rsync_dir=${main_dir}/rsync
    debug "rsync dir: ${rsync_dir}"
    if [ -e ${rsync_dir} ]
    then
        BACKUPS=${main_dir}/archive

        if [ ! -e ${BACKUPS} ]
        then
             mkdir -p ${BACKUPS}
        fi

        find ${BACKUPS} -name "*.tar" -mtime +7 -exec rm {} \;

        for j in `ls ${rsync_dir}/home`; do
            debug "========="
            debug ${j}
            DIRNAME=${rsync_dir}/home/${j}
            debug ${DIRNAME}
            if [ -e ${DIRNAME}/www ]
            then
                DATE=`date +%Y-%m-%d_%H_%M`
                FILENAME="${BACKUPS}/${j}_${DATE}.tar"
                debug ${FILENAME}
                tar -C ${DIRNAME} -cf ${FILENAME} www
            fi
            debug ''
        done
    fi
done

debug "end"
DT=`date "+%Y-%m-%d_%H-%M"`
debug ${DT}

IFS=$ORIGIFS
OFS=$ORIGOFS


