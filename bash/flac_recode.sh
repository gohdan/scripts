#!/bin/bash
for i in *.flac; do
    OF=$i
    mplayer -vo null -vc null -ao pcm:fast:file=audio.wav "$i"
	lame -h -V 4 audio.wav "${i%.flac}".mp3
	rm audio.wav
done
