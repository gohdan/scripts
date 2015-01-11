#!/bin/sh

# usage: mass_recode.sh /my/directory utf8
# $1 - directory with files to encode
# $2 - target encoding

DEBUG=0 # 1 - echo debug info, 0 - don't echo

ORIGIFS=$IFS
ORIGOFS=$OFS;

if [[ '' != $1 ]]
then
	if [ "1" == "$DEBUG" ]; then echo 'directory: '$1; fi

	if [[ '' != $2 ]]
	then
		if [ "1" == "$DEBUG" ]; then echo 'target encoding: '$2; fi

			WI=`whereis enca | sed -e "s/enca://g"`
			if [ "1" == "$DEBUG" ]; then echo "enca path: "$WI; fi

			if [[ '' != "$WI" ]]
			then
				if [ "1" == "$DEBUG" ]; then echo 'found enca'; fi

				for i in `find $1 -type f -regextype posix-egrep -regex '.*(.php|.js|.css|.htm|.html|.xml|.ini)$'`; do
					if [ "1" == "$DEBUG" ]; then echo $i; fi
					if [ "1" == "$DEBUG" ]; then enca $i; fi
					enca -x $2 $i
				done

			else
				echo 'cannot find enca'
			fi


	else
		echo 'no target encoding given, try utf8'
	fi
else
	echo 'no target directory given'
fi

IFS=$ORIGIFS
OFS=$ORIGOFS

