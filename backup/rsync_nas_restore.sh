#!/bin/bash
export RSYNC_PASSWORD=password
IP=ip_address

rsync -zavP admin@$IP::NetBackup/ /root/testrestore
