#!/bin/sh
SQLHOST=localhost
CURDATE=`date "+%Y%m%d-%H%M%S"`
CLT=/usr/bin/mysql
DUMP=/usr/bin/mysqldump
BACKUPS=dumps

#for DBNAME in `$CLT -h$SQLHOST --execute='show databases' -N -s `
for DBNAME in `cat dbs_list.txt`
do
echo 'restoring '$DBNAME
mysql -h$SQLHOST $DBNAME < $BACKUPS/$DBNAME.sql
done

