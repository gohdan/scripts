#!/bin/bash

currentDate=`date +%F`
currentMonth=`date +%Y-%m`
currentDay=`date +%Y-%m-%d`
IP=ip_address
PASW=password
MYSQL_USER=root
MYSQL_PASS=***

# подключение к серверу rsync
backupServer=admin@$IP
export RSYNC_PASSWORD=$PASW

# логин-пароль mysql
dbusername=$MYSQL_USER
dbpassword=$MYSQL_PASS

# параметры для бэкапа базы данных
SQLHOST=localhost
PORT=3306
CLT=/usr/bin/mysql
DUMP=/usr/bin/mysqldump
IS="information_schema"
PS="performance_schema"

#backupdir=/root/testbackup/
www_root=/home/admin/web/example.org
www_dir=/home/admin/web/example.org/public_html
rsyncTmp=/tmp/rsync
rsyncMkdir=${rsyncTmp}mkdir/
backupdirDay=backup_${currentDay}/

mkdir ${rsyncTmp}

# rsync не умеет создавать директории. Немного извернёмся.
# rsync_mkdir relative/path destinationPath
rsync_mkdir ()
{
  mkdir -p ${rsyncMkdir}$1
  rsync -v --archive --compress --progress ${rsyncMkdir} $2
  rm -R ${rsyncMkdir}
}
rsync_mkdir ${backupdirDay} ${backupServer}

# Дампим базы данных

for DBNAME in `$CLT -h$SQLHOST -P $PORT -u $dbusername -p$dbpassword --execute='show databases' -N -s `
do
if [ "$IS" != "$DBNAME" ]
then
        if [ "$PS" != "$DBNAME" ]
        then
                FILENAME=${rsyncTmp}/db_${DBNAME}_${currentDate}.sql.bz2
                echo 'dumping '$DBNAME' to '$FILENAME
                $DUMP -h$SQLHOST -P $PORT -u$dbusername -p$dbpassword $DBNAME | bzip2 -9 > $FILENAME
        fi
fi
done



FILENAME="${rsyncTmp}/www_${currentDate}.tar.bz2"
tar -C ${www_root} -jcf $FILENAME $www_dir

# Отсылаем всю директорию на NAS.
#
# --delete-after --force после завершения копирования удаляет на NAS всё, чего
# больше нет в исходнике.
# --partial позволяет докачивать прерванные загрузки. Полезно, если соединение не очень.
# --compress жать перед отправкой, разжимать на NAS.
# --archive сохраняем атрибуты файлов.
# -v --progress показываем прогресс загрузки и другие сообщения.
#
# rsync_dir sourcePath destinationPath
# rsync -v --archive --compress --progress --delete-after --force --partial $1 $2

rsync -v --archive --compress --progress --force --partial ${rsyncTmp} ${backupServer}/${backupdirDay}

rm -rf ${rsyncTmp}

