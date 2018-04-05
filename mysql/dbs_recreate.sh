#!/bin/sh
SQLHOST=localhost
CURDATE=`date "+%Y%m%d-%H%M%S"`
CLT=/usr/bin/mysql
DUMP=/usr/bin/mysqldump
BACKUPS=dumps

#for DBNAME in `cat dbs_recreate.txt`
for DBNAME in `$CLT -h$SQLHOST --execute='show databases' -N -s `
do
echo "recreating \`${DBNAME}\`"
$CLT -h$SQLHOST --execute="drop database \`${DBNAME}\`" -N -s
$CLT -h$SQLHOST --execute="create database \`${DBNAME}\`" -N -s
done

