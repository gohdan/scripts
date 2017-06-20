#!/bin/sh

SWAP=`free -m | grep Swap | awk '{print $3}'`
THRESHOLD=1024

#echo 'swap volume: '$SWAP

if [ $SWAP -ge $THRESHOLD ]
then
#       echo 'too much swap'
        /sbin/service php-fpm restart
fi



LA=`uptime | awk '{print $10+0}'`
THRESHOLD=3

#echo 'load average: '$LA

if [ $LA -ge $THRESHOLD ]
then
#       echo 'too big load average'
        /sbin/service php-fpm restart
fi

