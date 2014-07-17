#!/bin/sh
file=/tmp/reconnect_data
log=/var/log/reconnect.log

if [[ -e $file ]]
then
	echo "reconnect data file exists"
	rm $file
fi

ping ya.ru -c 3 | grep "from" > $file

if [[ ! -s $file ]]
then
		echo "*** `date` ***"
        echo "not connected to Internet"
        echo "`date`: ifconfig"
		/sbin/ifconfig
        /sbin/service network restart
        sleep 5
        ping ya.ru -c 3
        echo "`date`: ifconfig"
        /sbin/ifconfig
fi

if [[ -e $file ]]
then
	rm $file
fi

