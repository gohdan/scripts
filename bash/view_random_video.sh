#!/bin/sh

ORIGIFS=$IFS
ORIGOFS=$OFS;

IFS=$(echo -en "\n\b")
OFS=$(echo -en "\n\b")

DIR=$1

if [ "" == "$DIR" ]
then
	DIR="."
fi

echo $DIR

FLOOR=1
RANGE=`ls $DIR | wc -l`
number=0   #initialize
while [ "$number" -le $FLOOR ]
do
  number=$RANDOM
  let "number %= $RANGE"  # Ограничение "сверху" числом $RANGE.
done

j=0
for i in `ls $DIR`; do
	j=`echo $j+1 | bc`
	#echo $j
	if [ "$j" -eq "$number" ]
	then
		mplayer $DIR/$i
		break
	fi
done

IFS=$ORIGIFS
OFS=$ORIGOFS
