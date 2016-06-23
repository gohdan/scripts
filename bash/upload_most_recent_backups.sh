#!/bin/sh

HOST="ftp.example.org"
USER="user"
PASS="password"
FTPURL="ftp://$USER:$PASS@$HOST"
LCD="backup"
RCD="backup"

FILE1=`find $LCD/apache/ -type f -exec stat -c "%Y %n" {} \; | sort -n | tail -1 | cut -d' ' -f2`

FILE2=`find $LCD/mysql/ -type f -exec stat -c "%Y %n" {} \; | sort -n | tail -1 | cut -d' ' -f2`


FILES=( $FILE1 $FILE2 );

for FILE in ${FILES[*]}; do

lftp -c "set ftp:list-options -a;
open '$FTPURL';
cd $RCD;
put $FILE;
bye;"

done

