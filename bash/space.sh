#!/bin/sh

# Минимальный процент свободного места
qu=50
# Файл, куда кидаем временные данные
file=/tmp/space.txt

df | head -n 2 | tail -n 1 > $file

all=`cat $file | awk ' {print $4}'`
#echo "all:   "$all
used=`cat $file | awk ' {print $3}'`
#echo "used:  "$used
free=`echo $all"-"$used | bc`
#echo "free:  "$free
limit=`echo $all"/100*"$qu | bc`
#echo "limit:  "$limit
if [ "$free" -le "$limit" ]
then
	echo "to small free space left"
fi

rm $file

