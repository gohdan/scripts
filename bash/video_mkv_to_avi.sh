#!/bin/sh


mencoder "$1" -oac copy -ovc xvid -xvidencopts pass=1 -o /dev/null
mencoder "$1" -oac copy -ovc xvid -xvidencopts pass=2:bitrate=800 -o "$1".avi
