#!/bin/sh
SQLHOST=localhost
CURDATE=`date "+%Y%m%d-%H%M%S"`
CLT=/usr/bin/mysql
DUMP=/usr/bin/mysqldump

$CLT -h$SQLHOST --execute='show databases' -N -s > dbs_list.txt

