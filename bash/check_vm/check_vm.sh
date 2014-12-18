#!/bin/bash

DIR=/opt/check_vm
EXPECTSCRIPT="$DIR/telnet_script"
TMPFILE=/tmp/check_vm_telnet_log.txt
DELAY=10

VMS=(
	vm1
	vm2
	vm3
)

for VM in ${VMS[*]}; do

        #echo "checking $VM"
        HOST="vm-$VM"
        expect $EXPECTSCRIPT $HOST > $TMPFILE


        if [ "`grep Connected $TMPFILE`" ]
        then
                #echo "$VM is up"
                :
        else
                echo "$VM is down"
                echo "trying to shutdown"
                /usr/bin/virsh shutdown $VM
                sleep $DELAY
                echo "trying to destroy"
                /usr/bin/virsh destroy $VM
                sleep $DELAY
                echo "trying to start"
                /usr/bin/virsh start $VM
        fi

        if [ -e $TMPFILE ]
        then
                rm $TMPFILE
        fi
done

exit 0
