#!/bin/sh
grep 'nameserver' /etc/resolv.conf | awk '{print "NS"NR" "$2}' 
