#!/bin/sh

ffmpeg -i $1 -c:v libx264 -c:a copy -preset ultrafast output.mp4
