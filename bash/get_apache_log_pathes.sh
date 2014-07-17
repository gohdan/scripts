#!/bin/sh

grep -i customlog /etc/httpd/conf/httpd.conf | grep -v "#" | awk '{print $2}' | sed 's/access.log//' | sort

