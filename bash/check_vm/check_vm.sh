#!/bin/bash

DIR=/opt/check_vm
EXPECTSCRIPT="$DIR/telnet_script"
TMPFILE=/tmp/check_vm_telnet_log.txt
DELAY=10
LA_THRESHOLD=90

VMS=(
        apache
)

function restart_vm()
{
        VM=$1

        echo "trying to shutdown"
        /usr/bin/virsh shutdown $VM
        sleep $DELAY
        echo "trying to destroy"
        /usr/bin/virsh destroy $VM
        sleep $DELAY
        echo "trying to start"
        /usr/bin/virsh start $VM
}

for VM in ${VMS[*]}; do

        #echo "checking $VM"
        HOST="vm-$VM"
        expect $EXPECTSCRIPT $HOST > $TMPFILE

        #echo $results


        if [ "`grep Connected $TMPFILE`" ]
        then
                #echo "$VM is up"
                LA=`grep "load.value" $TMPFILE | awk '{print $2}' | awk -F . '{print $1}'`
                #echo "LA: $LA"
                if [ -n "$LA" ]
                then
                        if [ "$LA" -gt "$LA_THRESHOLD" ]
                        then
                                echo "$VM load average is too high: $LA"

                                echo "=== Connection protocol ==="
                                cat $TMPFILE
                                echo "==========================="

                                restart_vm $VM
                        fi
                else
                        echo "Cannot get load average value, it seems that $VM is down"

                        echo "=== Connection protocol ==="
                        cat $TMPFILE
                        echo "==========================="

                        restart_vm $VM
                fi
        else
                echo "$VM is down"

                echo "=== Connection protocol ==="
                cat $TMPFILE
                echo "==========================="

                restart_vm $VM
        fi

        if [ -e $TMPFILE ]
        then
                rm $TMPFILE
        fi
done

exit 0

