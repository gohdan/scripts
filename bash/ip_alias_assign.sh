#!/bin/bash

IF_DIR="/etc/sysconfig/network-scripts"

function assign_alias_ip
{
    echo "*** assign_alias_ip ***"
    if [ -z ${IDX+x} ]; then IDX=0; fi
    echo "IDX: ${IDX}"

    egrep -v "IPADDR|DEVICE|BOOTPROTO|NAME" ${IF_DIR}/ifcfg-eth0 > ${IF_DIR}/ifcfg-eth0:${IDX}
    echo "BOOTPROTO=\"static\"" >> ${IF_DIR}/ifcfg-eth0:${IDX}
    echo "IPADDR=\"${IP}\"" >> ${IF_DIR}/ifcfg-eth0:${IDX}
    echo "DEVICE=\"eth0:${IDX}\"" >> ${IF_DIR}/ifcfg-eth0:${IDX}
    echo "NAME=\"eth0:${IDX}\"" >> ${IF_DIR}/ifcfg-eth0:${IDX}
    ifup eth0:${IDX}
    echo "*** end: assign_alias_ip ***"
    return 0
}

for IP in `cat /root/scripts/ip_list.txt`
do
    echo ${IP}
    qty=`ip a | grep -c ${IP}`
    echo "qty: ${qty}"
    if [ "0" == "${qty}" ]
    then
        echo "assign"
        if [ -e "${IF_DIR}/ifcfg-eth0:0" ]
        then
            echo "already have an alias"

            for i in `ls ${IF_DIR}/ifcfg-eth0:* | awk -F : '{print $2}' | sort`
            do
                echo ${i}
            done

            echo "max_alias: ${i}"

            let IDX=${i}+1
            assign_alias_ip
        else
            echo "no alias yet, creating first"
            IDX=0
            assign_alias_ip
        fi
    fi
done

