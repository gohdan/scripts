#!/bin/bash
SQLHOST=localhost
CLT=/usr/bin/mysql
USR=root
DUMP=/usr/bin/mysqldump
BACKUPS=/home/backup/db
IS="information_schema"
PS="performance_schema"
PORT=3306

if [ ! -e ${BACKUPS} ]
then
	mkdir -p ${BACKUPS}
fi

find ${BACKUPS} -name "*.bz2" -mtime +7 -exec rm {} \;

echo ''

CURDATE=`date "+%Y-%m-%d_%H-%M"`
for DBNAME in `${CLT} -h${SQLHOST} -P ${PORT} -u${USR} --execute='show databases' -N -s`
do
if [ "${IS}" != "${DBNAME}" ]
then

        if [ "${PS}" != "${DBNAME}" ]
        then
            HOST=`hostname`
            FILENAME=${BACKUPS}/${HOST}_${DBNAME}_${CURDATE}.sql
            echo 'dumping '${DBNAME}' to '${FILENAME}
            ${DUMP} -RE -h${SQLHOST} -P ${PORT} -u${USR} ${DBNAME} > ${FILENAME}
            bzip2 ${FILENAME}
        fi
fi
done

