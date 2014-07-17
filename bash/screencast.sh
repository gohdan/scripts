#!/bin/sh
ffmpeg -r 60 -g 600 -s 1280x1024 -f x11grab -i :0.0 -vcodec ffv1 screencast.avi

