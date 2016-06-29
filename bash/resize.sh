#!/bin/sh
# $1 - name of the subdir
# $2 - width of the image

ORIGIFS=$IFS
ORIGOFS=$OFS;

IFS=$(echo -en "\n\b")
OFS=$(echo -en "\n\b")

mkdir $1;
for f in `find . -maxdepth 1 -type f`; do
	echo "resizing "$f
	convert -resize $2 "$f" "$1/${f%}" ;
done

IFS=$ORIGIFS
OFS=$ORIGOFS

