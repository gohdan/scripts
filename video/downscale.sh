#!/bin/sh
ORIGIFS=$IFS
ORIGOFS=$OFS;

IFS=$(echo -en "\n\b")
OFS=$(echo -en "\n\b")

mencoder ${1} -o out.avi -of lavf -oac pcm -ovc lavc -lavcopts vcodec=mpeg4 -vf scale=480:270

IFS=$ORIGIFS
OFS=$ORIGOFS

