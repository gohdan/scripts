#!/bin/bash

currentDate=`date +%F`
currentMonth=`date +%Y-%m`
currentDay=`date +%Y-%m-%d`
IP=ip_address
RSYNC_PASS=password

# подключение к серверу rsync
backupServer=admin@$IP::NetBackup/
export RSYNC_PASSWORD=$RSYNC_PASS

# логин-пароль mysql
dbusername=root
dbpassword=***

# параметры для бэкапа базы данных
SQLHOST=localhost
PORT=3306
CLT=/usr/bin/mysql
DUMP=/usr/bin/mysqldump
IS="information_schema"
PS="performance_schema"

#backupdir=/root/testbackup/
www_dir=/home/admin/web/example.org/public_html
rsyncTmp=/tmp/rsync
rsyncDb=/tmp/db
rsyncMkdir=${rsyncTmp}mkdir/
targetdir=public_html

mkdir ${rsyncTmp}
mkdir ${rsyncDb}

# rsync не умеет создавать директории. Немного извернёмся.
# rsync_mkdir relative/path destinationPath
rsync_mkdir ()
{
  mkdir -p ${rsyncMkdir}$1
  rsync -v --archive --compress --progress ${rsyncMkdir} $2
  rm -R ${rsyncMkdir}
}
rsync_mkdir ${targetdir} ${backupServer}
rsync_mkdir ${targetdir}/db ${backupServer}

# Дампим базы данных

for DBNAME in `$CLT -h$SQLHOST -P $PORT -u $dbusername -p$dbpassword --execute='show databases' -N -s `
do
if [ "$IS" != "$DBNAME" ]
then
        if [ "$PS" != "$DBNAME" ]
        then
                FILENAME=${rsyncDb}/db_${DBNAME}_${currentDate}.sql.bz2
                echo 'dumping '$DBNAME' to '$FILENAME
                $DUMP -h$SQLHOST -P $PORT -u$dbusername -p$dbpassword $DBNAME | bzip2 -9 > $FILENAME
        fi
fi
done


# Опции rsync
# --delete-after --force после завершения копирования удаляет на NAS всё, чего больше нет в исходнике.
# --partial позволяет докачивать прерванные загрузки. Полезно, если соединение не очень.
# --compress жать перед отправкой, разжимать на NAS.
# --archive сохраняем атрибуты файлов.
# -v --progress показываем прогресс загрузки и другие сообщения.
# rsync_dir sourcePath destinationPath
# rsync -v --archive --compress --progress --delete-after --force --partial $1 $2

# Отсылаем дампы БД
rsync -v --archive --compress --progress --partial ${rsyncDb} ${backupServer}/${targetdir}
rm -rf ${rsyncDb}

# Отсылаем www-директорию на NAS.
rsync -v --archive --compress --progress --partial ${www_dir} ${backupServer}/${targetdir}

rm -rf ${rsyncTmp}


