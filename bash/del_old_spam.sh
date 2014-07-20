#!/bin/sh

find /home/spam/Maildir/new -mtime +7 -exec rm -rf {} \;
