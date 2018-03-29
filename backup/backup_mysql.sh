#!/bin/sh

SYSTEMUSER=systemuser

SQLHOST=localhost
CLT=/usr/bin/mysql
USR=root
PSW=passwd
DUMP=/usr/bin/mysqldump
BACKUPS=/home/$SYSTEMUSER/backup/mysql
IS="information_schema"
PS="performance_schema"
PORT=3306

find $BACKUPS -name "*.bz2" -mtime +7 -exec rm {} \;

#echo ''

CURDATE=`date "+%Y-%m-%d"`

DBNAME=$SYSTEMUSER
FILENAME=$BACKUPS/$DBNAME_$CURDATE.sql
$DUMP -E -h$SQLHOST -P $PORT -u$USR -p$PSW $DBNAME > $FILENAME
bzip2 $FILENAME

chown $SYSTEMUSER:$SYSTEMUSER $FILENAME.bz2
