#!/bin/sh

for i in `ls /etc/named/`; do
sed -r 's/8.8.8.4/8.8.8.8/g' $i > /etc/named/$i;
done ;
