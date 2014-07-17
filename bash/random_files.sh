#!/bin/sh

FILES=10
NUMBERS=10

i=0

while [ "$i" -lt "$FILES" ]
do
	name=$RANDOM
	touch $name.txt

	j=0
	while [ "$j" -lt "$NUMBERS" ]
	do
		number=$RANDOM
		echo $number >> $name.txt
		j=$((j+1))
	done
	
	i=$((i+1))
done
