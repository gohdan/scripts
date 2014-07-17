#!/bin/sh
FLOOR=$1
RANGE=$2
number=0   #initialize
while [ "$number" -le $FLOOR ]
do
  number=$RANDOM
  let "number %= $RANGE"  # Ограничение "сверху" числом $RANGE.
done
echo "Случайное число в диапазоне от $FLOOR до $RANGE ---  $number"
echo
