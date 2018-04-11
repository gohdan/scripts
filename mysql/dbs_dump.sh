#!/bin/sh
SQLHOST=localhost
CURDATE=`date "+%Y%m%d-%H%M%S"`
CLT=/usr/bin/mysql
DUMP=/usr/bin/mysqldump
BACKUPS=dumps

#for DBNAME in `cat dbs_2dump.txt`
for DBNAME in `$CLT -h$SQLHOST --execute='show databases' -N -s `
do
echo 'dumping '$DBNAME
$DUMP -R -E -h$SQLHOST $DBNAME >$BACKUPS/$DBNAME.sql
done

