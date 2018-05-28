#!/bin/sh

BACKUPS=/backups/files
DATE=`date +%Y-%m-%d_%H-%M`

find $BACKUPS -name "*.tar" -mtime +45 -exec rm {} \;

for i in `find /var/www/*/data/www/* -maxdepth 0 -type d | sed -e 's#^/##'`; do
        #echo "========="
        #echo $i
        FNAME=`basename ${i}`
        FILENAME="$BACKUPS/${FNAME}_$DATE.tar"
        #echo $FILENAME
        tar -C / -cf $FILENAME $i
        #echo ''
done
