#!/bin/sh

ORIGIFS=$IFS
ORIGOFS=$OFS;

IFS=$(echo -en "\n\b")
OFS=$(echo -en "\n\b")

mplayer $1 -vo null -vc null -ao pcm:fast
lame -V 0 -h audiodump.wav $1.mp3
if [ -e audiodump.wav ]
then
	rm audiodump.wav
fi

IFS=$ORIGIFS
OFS=$ORIGOFS
