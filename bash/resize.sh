#!/bin/sh
# $1 - name of the subdir
# $2 - width of the image

mkdir $1;
for f in *; do
	echo "resizing "$f
	convert -resize $2 "$f" "$1/${f%}" ;
done
