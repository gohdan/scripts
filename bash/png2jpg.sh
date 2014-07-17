#!/bin/sh
for f in *.png; do convert -background black -alpha Background "$f" "jpg/${f%}.jpg" ; done
