#!/bin/sh

i=userdir

DATE=`date +%Y-%m-%d`
BACKUPS=/home/$i/backup/apache

find $BACKUPS -name "*.bz2" -mtime +7 -exec rm {} \;

DIRNAME=/home/$i
FILENAME="$BACKUPS/${i}_$DATE.tar.bz2"
tar -C $DIRNAME -jcf $FILENAME www
chown -R $i:$i $FILENAME
