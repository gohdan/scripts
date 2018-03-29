#!/bin/sh
SQLHOST=localhost
CLT=/usr/bin/mysql
USR=root
PSW=***
DUMP=/usr/bin/mysqldump
BACKUPS=/home/backup/mysql
IS="information_schema"
PS="performance_schema"
PORT=3306

find $BACKUPS -name "*.bz2" -mtime +7 -exec rm {} \;

echo ''

CURDATE=`date "+%Y-%m-%d"`
for DBNAME in `$CLT -h$SQLHOST -P $PORT -u$USR -p$PSW --execute='show databases' -N -s `
do
if [ "$IS" != "$DBNAME" ]
then

        if [ "$PS" != "$DBNAME" ]
        then

        FILENAME=$BACKUPS/$DBNAME.$CURDATE.sql
        echo 'dumping '$DBNAME' to '$FILENAME
        $DUMP -h$SQLHOST -P $PORT -u$USR -p$PSW $DBNAME > $FILENAME
        bzip2 $FILENAME

        fi
fi
done
