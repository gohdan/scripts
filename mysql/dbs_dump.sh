#!/bin/sh
SQLHOST=localhost
CURDATE=`date "+%Y%m%d-%H%M%S"`
CLT=/usr/bin/mysql
DUMP=/usr/bin/mysqldump
BACKUPS=dumps
IS="information_schema"
PS="performance_schema"

#for DBNAME in `cat dbs_2dump.txt`
for DBNAME in `$CLT -h$SQLHOST --execute='show databases' -N -s `
do
if [ "$IS" != "$DBNAME" ]
then
        if [ "$PS" != "$DBNAME" ]
        then
			echo 'dumping '$DBNAME
			$DUMP -R -E -h$SQLHOST $DBNAME >$BACKUPS/$DBNAME.sql
		fi
fi
done

