#!/bin/sh
mencoder $1 -o out.avi -of lavf -oac pcm -ovc lavc -lavcopts vcodec=mpeg4 -vf scale=480:270
