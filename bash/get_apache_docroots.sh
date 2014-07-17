#!/bin/sh
grep -i documentroot /etc/httpd/conf/httpd.conf | grep -v "#" | awk '{print $2}' | sort

