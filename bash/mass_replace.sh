#!/bin/sh
echo "replacing $1 to $2";
for i in *; do
	echo $i;
	sed -i "s/$1/$2/g" $i;
done
