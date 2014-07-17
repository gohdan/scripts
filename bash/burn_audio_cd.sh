#!/bin/sh

mkdir cd_tmp
for i in *
do mplayer "$i" -ao pcm -aofile "cd_tmp/$i.wav"
 sox "cd_tmp/$i.wav" "cd_tmp/$i.cdr"
 rm "cd_tmp/$i.wav"
done
cdrecord -v speed=24 -audio cd_tmp/*cdr
wait
rm -rf cd_tmp
exit 0

