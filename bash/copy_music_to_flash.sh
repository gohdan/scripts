#!/bin/sh


#if [ $# != 1 ]
#then
#        echo
#        echo USAGE: mp3toogg \<quality\> \(integer from -1 to 10\)
#        echo
#        exit 1
#fi


ORIGIFS=$IFS
ORIGOFS=$OFS;

IFS=$(echo -en "\n\b")
OFS=$(echo -en "\n\b")


# find -name '*.mp3'
for i in `find $1 | grep -i 'mp3' | sort`; do
	echo $i
	cp --parents $i $2
done 

IFS=$ORIGIFS
OFS=$ORIGOFS
