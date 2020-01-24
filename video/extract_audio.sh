#!/bin/sh

ORIGIFS=$IFS
ORIGOFS=$OFS;

IFS=$(echo -en "\n\b")
OFS=$(echo -en "\n\b")

# variant
# mencoder "$1" -of rawaudio -oac mp3lame -ovc copy -o audio.mp3

mplayer "${1}" -vo null -vc null -ao pcm:fast -o audiodump.wav

lame -V 0 -h audiodump.wav "${1}.mp3"

if [ -e audiodump.wav ]
then
	rm audiodump.wav
fi

IFS=$ORIGIFS
OFS=$ORIGOFS
