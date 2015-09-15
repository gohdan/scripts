#!/bin/sh

if [ "" == "$1" ]
then
echo "ISO file is not given"
else

	if [ "" == "$2" ]
	then
	echo "output device is not given"
	else

		pv $1 | dd oflag=direct of=$2 bs=1M
		sync
	fi
fi
