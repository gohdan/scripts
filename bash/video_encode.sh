#!/bin/sh
# $1 - filename

rm divx2pass.log
rm divx2pass.log.mbtree

mencoder $1 -o /dev/null -nosound -ovc x264 -x264encopts bitrate=1800:pass=1:subq=1:frameref=1
mencoder $1 -o out.mkv -of lavf -oac mp3lame -lameopts vbr=3:br=64:mode=3 -ovc x264 -x264encopts bitrate=1800:pass=2

rm divx2pass.log
rm divx2pass.log.mbtree

