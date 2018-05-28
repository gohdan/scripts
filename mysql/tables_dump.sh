#!/bin/bash

#!/bin/sh
SQLHOST=localhost
CURDATE=`date "+%Y%m%d-%H%M%S"`
CLT=/usr/bin/mysql
DUMP=/usr/bin/mysqldump
BACKUPS=dumps
DBNAME=db_name


for TBLNAME in `$CLT -h$SQLHOST $DBNAME --execute='show tables' -N -s `
do

	echo 'dumping '$TBLNAME
	#$DUMP -R -E --skip-extended-insert -h$SQLHOST $DBNAME $TBLNAME >$BACKUPS/$TBLNAME.sql
	$DUMP -R -E -h$SQLHOST $DBNAME $TBLNAME >$BACKUPS/$TBLNAME.sql

done


