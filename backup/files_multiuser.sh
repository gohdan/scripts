#!/bin/sh

BACKUPS=/backups/files
DATE=`date +%Y-%m-%d_%H_%M`

find $BACKUPS -name "*.bz2" -mtime +7 -exec rm {} \;

for i in `ls /home/`; do
        #echo "========="
        #echo $i
        DIRNAME=/home/$i
        #echo $DIRNAME
        if [ -e $DIRNAME/www ]
        then
                FILENAME="$BACKUPS/${i}_$DATE.tar.bz2"
                echo $FILENAME
                #echo "-C $DIRNAME -rf $FILENAME www"
                tar -C $DIRNAME -jcf $FILENAME www
        fi
        echo ''
done
