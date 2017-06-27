#!/bin/sh

HOST=localhost
PORT=3306
CLT=/usr/bin/mysql
USR=***
PSW=****
DB=****

COLUMNS=`$CLT -B -N -u $USR -p$PSW -h $HOST -P $PORT $DB -e "SHOW TABLES"`

for i in $COLUMNS; do
        QUERY="CHECK TABLE ${i}";
        echo $QUERY;
        $CLT -u $USR -p$PSW -h $HOST -P $PORT $DB -e "${QUERY}";
done

