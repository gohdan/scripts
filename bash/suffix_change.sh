#!/bin/sh
for i in * ; do f=`basename $i .jpg`_thumb.jpg ; echo $i $f; mv $i $f; done
