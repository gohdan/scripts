#!/bin/bash

ffmpeg -i input.avi -c:v libx264 -c:a aac -preset ultrafast -qp 0 output.mp4
