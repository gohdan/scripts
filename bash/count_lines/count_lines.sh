#!/bin/bash


TMP=tmp_`date +%s`
TMPTMP=tmptmp_`date +%s`
UNPR=$1"_unprocessed"

if [ -e $UNPR ]
then
	mv $UNPR $UNPR"_"`date +%s`
fi

if [ -e $1 ]
then
	cp $1 $TMP
else
	touch $TMP
fi
 
while [ -s $TMP ]
do
	line=`head $TMP -n 1`

	n=`grep -Fx "${line}" $TMP | wc -l`
	grep -vFx "${line}" $TMP > $TMPTMP

	size1=`ls -l $TMP | awk '{print $5}'`
	size2=`ls -l $TMPTMP | awk '{print $5}'`

	if [ "$size1" -eq "$size2" ]
	then
		# grep failed, skipping line
		echo $line >> $UNPR
		let count=`wc -l $TMP`
		let toskip=($count - 1)
		tail -n $toskip $TMP > $TMPTMP
	else
		# all ok
	    echo "$n $line"
	fi

	mv $TMPTMP $TMP
done

if [ -e $TMP ]
then
	rm $TMP
fi

if [ -e $TMPTMP ]
then
	rm $TMPTMP
fi
 
exit 0
