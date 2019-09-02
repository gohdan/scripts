#!/bin/sh

BACKUPS=/home/backup/files

if [ ! -e ${BACKUPS} ]
then
	mkdir -p ${BACKUPS}
fi

find ${BACKUPS} -name "*.tar" -mtime +1 -exec rm {} \;

for i in `ls /home/`; do
        echo "========="
        echo ${i}
        DIRNAME=/home/${i}
        echo ${DIRNAME}
        if [ -e ${DIRNAME}/www ]
        then
                DATE=`date +%Y-%m-%d_%H_%M`
                FILENAME="${BACKUPS}/${i}_${DATE}.tar"
                echo ${FILENAME}
                tar -C ${DIRNAME} -cf ${FILENAME} www
        fi
        echo ''
done


