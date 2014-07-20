#!/bin/sh

# Convert ISA rules to squid ACL

ORIGIFS=$IFS
ORIGOFS=$OFS;

IFS=$(echo -en "\n\b")
OFS=$(echo -en "\n\b")

ISADIR=/tmp/ISA
ALLRULES=/tmp/ISA/all.txt
TEMPRULES=/tmp/ISA/temp.txt
ACLFILE=/etc/squid/urls_block.acl
WHITELIST=/etc/squid/urls_allow.acl

if [ -e $ISADIR ]
then
        rm -rf $ISADIR
fi

mkdir -p $ISADIR

HOST="ftp.***.ru"
USER="***"
PASS="***"
FTPURL="ftp://$USER:$PASS@$HOST"
LCD=$ISADIR
RCD="ISA"

lftp -c "set ftp:list-options -a;
open '$FTPURL';
lcd $LCD;
cd $RCD;
mirror -e --verbose --exclude-glob old/
bye"

if [ -e $ALLRULES ]
then
        rm $ALLRULES;
fi

if [ -e $TEMPRULES ]
then
        rm $TEMPRULES;
fi

echo ''
echo 'converting ISA rules to squid ACL:'

for i in `ls $ISADIR`; do
        echo "$i"
        cat "$ISADIR/$i" >> $ALLRULES
        echo '' >> $ALLRULES
done

dos2unix -q $ALLRULES

echo ''
if [ -e $ALLRULES ]
then
        echo "all rules qty: "`wc -l $ALLRULES | awk '{print $1}'`

        for i in `cat $ALLRULES`; do
                echo $i | sed -e 's/http:\/\///ig' | sed -e 's/https:\/\///ig' | sed -e 's/\/\*//ig' | sed -e 's/\*\./\./ig' | sed -e 's/^\.//ig' >> $TEMPRULES
        done

        sort -u $TEMPRULES > $ACLFILE

        for i in `cat $WHITELIST`; do
                grep -v $i $ACLFILE > $TEMPRULES
                mv $TEMPRULES $ACLFILE
        done

        echo "final rules qty: "`wc -l $ACLFILE | awk '{print $1}'`
        echo ''

        rm $ALLRULES

        if [ -e $TEMPRULES ]
        then
                rm $TEMPRULES
        fi

        rm -rf $ISADIR

        service squid reload
else
        echo "got no rules, doing nothing"
fi

IFS=$ORIGIFS
OFS=$ORIGOFS

