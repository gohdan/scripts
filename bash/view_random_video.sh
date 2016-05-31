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

FILE=/tmp/files
find $DIR -type f > $FILE

FLOOR=1
RANGE=`wc -l $FILE | awk '{print $1}'`
number=0   #initialize
while [ "$number" -le $FLOOR ]
do
  number=$RANDOM
  let "number %= $RANGE"  # Ограничение "сверху" числом $RANGE.
done

FILENAME=`head -n $number $FILE | tail -n 1`

mplayer $FILENAME

rm $FILE

IFS=$ORIGIFS
OFS=$ORIGOFS
