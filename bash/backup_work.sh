#!/bin/sh

PREFIX=/home/gohdan
BACKUP=$PREFIX/yandex/backup
TMPDIR=/tmp
ARCHPSW=***

DATE=`date "+%Y-%m-%d"`

#find $BACKUP -mtime +3 -exec rm -rf {} \;

for DIR in "work" "docs"; do
	mkdir -p $BACKUP/$DATE/$DIR

	for i in `ls $PREFIX/$DIR`; do
		7za a -mx=8 -p$ARCHPSW -w$TMPDIR $TMPDIR/$i.7z $PREFIX/$DIR/$i
		mv $TMPDIR/$i.7z $BACKUP/$DATE/$DIR
		sleep 30
	done
done

chown -R gohdan:gohdan $BACKUP/$DATE
