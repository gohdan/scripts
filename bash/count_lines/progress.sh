#!/bin/sh

orig=`wc -l $1 | awk '{print $1}'`
temp=`wc -l $2 | awk '{print $1}'`

size=`du -sh $2 | awk '{print $1}'`

if [ -e $1"_unprocessed" ]
then
	unpr=`wc -l $1"_unprocessed"`
else
	unpr=0
fi

#echo "orig: "$orig
#echo "temp: "$temp

let "perc=$orig / 100"

#echo "perc: "$perc

let "res=100 - $temp / $perc"

echo $res"% complete, "$temp" lines remain, temp file size is "$size", "$unpr" lines unprocessed"

exit 0
