#!/bin/sh

BACKUPS=/home/backup/configs
DATADIR=/
DIRNAME=etc
DATE=`date +%Y_%m_%d`

find ${BACKUPS} -name "*.tar" -mtime +7 -exec rm {} \;

FILENAME="${BACKUPS}/etc_${DATE}.tar"
echo ${FILENAME}
tar -C ${DATADIR} -cf ${FILENAME} ${DIRNAME}

