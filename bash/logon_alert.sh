#!/bin/sh

# /etc/profile.d/alert.sh

message="`date`, host: `hostname`, user: `whoami`"
subject="`whoami` logged to `hostname`"

echo $message | mail -s "$subject" root
