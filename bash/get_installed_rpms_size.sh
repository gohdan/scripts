#!/bin/sh

FILE=/tmp/rpms_sizes.txt
FILESORTED=/tmp/rpms_sizes_sorted.txt

for i in `rpm -qa`; do
	size=`rpm -qi $i | grep Size | awk '{print $3}'`;
	echo $size" "$i >> $FILE;
done

sort -rh $FILE > $FILESORTED

cat $FILESORTED

if [ -e $FILE ]
then
	rm $FILE
fi

if [ -e $FILESORTED ]
then
	rm $FILESORTED
fi


