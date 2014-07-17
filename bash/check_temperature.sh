#!/bin/sh

# $1 - threshold temperature

if [ -z $1 ]
then
	threshold=100
else
	threshold=$1
fi

#echo $threshold

PATH=/usr/bin/:/bin/

init_dbus() {
    user=`whoami`
    pids=`pgrep -u $user nautilus`
    for pid in $pids; do
		#echo $pid
        # find DBUS session bus for this session
        DBUS_SESSION_BUS_ADDRESS=`grep -z DBUS_SESSION_BUS_ADDRESS /proc/$pid/environ | sed -e 's/DBUS_SESSION_BUS_ADDRESS=//'`
        # use it
        export DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS
    done
}


# get_display [USER] — Returns $DISPLAY of USER.
# If first param is omitted, then $LOGNAME will be used.
get_display () {
who \
| grep ${1:-$LOGNAME} \
| perl -ne 'if ( m!\(\:(\d+)\)$! ) {print ":$1.0\n"; $ok = 1; last} END {exit !$ok}'
}

DISPLAY=$(get_display) || exit
export DISPLAY
#echo $DISPLAY

if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]
then
	init_dbus
fi
#echo $DBUS_SESSION_BUS_ADDRESS

for i in `sensors | grep -i core | awk '{print $3}' | sed -e 's/+//' | sed -e 's/.0//ig' | sed -e 's/°C//ig'`; do
	#echo $i
	if [[ $i -ge $threshold ]]
	then
		DISPLAY=:0.0 notify-send -u critical -i abrt -t 1000 'OVERHEAT' $i' °C!'
	fi
done
