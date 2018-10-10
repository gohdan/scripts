#!/bin/bash

mount /mnt/yandex

find /mnt/yandex/backup/db -name "*.bz2" -mtime +7 -exec rm {} \;
find /mnt/yandex/backup/files -name "*.tar" -mtime +7 -exec rm {} \;

rsync -avzh /home/backup/db /mnt/yandex/backup/
rsync -avzh /home/backup/files /mnt/yandex/backup/

umount /mnt/yandex
