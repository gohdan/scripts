#!/bin/bash

SQLHOST=localhost
CURDATE=`date "+%Y%m%d-%H%M%S"`
CLT=/usr/bin/mysql
DUMP=/usr/bin/mysqldump
BACKUPS=db_tables
DBNAME=db_name
USER=user
PASS=pass

if [ ! -e ${BACKUPS} ]
then
	mkdir ${BACKUPS}
fi

for TBLNAME in `${CLT} -h ${SQLHOST} ${DBNAME} -u ${USER} -p${PASS} --execute='show tables' -N -s`
do
	echo 'dumping '${TBLNAME}
	#${DUMP} -R -E -h ${SQLHOST} ${DBNAME} ${TBLNAME} >${BACKUPS}/${TBLNAME}.sql
	${DUMP} -R -E --skip-extended-insert -h ${SQLHOST} -u ${USER} -p${PASS} ${DBNAME} ${TBLNAME} >${BACKUPS}/${TBLNAME}.sql
done

