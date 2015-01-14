#!/bin/sh

DEBUG=0

ORIGIFS=$IFS
ORIGOFS=$OFS;

IFS=$(echo -en "\n\b")
OFS=$(echo -en "\n\b")

function get_server_status()
{
        if [ "1" == "$DEBUG" ]; then echo "=== get_server_status ==="; fi

        service=$1

        if [ "1" == "$DEBUG" ]; then echo "service: "$service; fi

        good_status=("isrunning..." "выполняется...")

        response=`/sbin/service $service status`
        if [ "1" == "$DEBUG" ]; then echo "responce: $response"; fi

        status=`echo $response | awk '{print $4 $5}'`
        if [ "1" == "$DEBUG" ]; then echo "status: $status"; fi

        if_running="0"
        for st in ${good_status[*]}; do
                if [ "$st" == "$status" ]
                then
                        if_running="1"
                fi
        done
        if [ "1" == "$DEBUG" ]; then echo "if running: $if_running"; fi

        return $if_running
}

function check_service()
{
        if [ "1" == "$DEBUG" ]; then echo "=== check_service ==="; fi

        service=$1

        if [ "1" == "$DEBUG" ]; then echo "service: "$service; fi

        get_server_status $service
        if_running=$?
        if [ "1" == "$DEBUG" ]; then echo "if running: $if_running"; fi

        if [ "0" == "$if_running" ]
        then
                if [ "1" == "$DEBUG" ]; then echo "service is not running, trying to restart"; fi

                /sbin/service $service stop

                for i in `ps -A | grep $service`; do
                        pid=`echo $i | awk '{ print $1 }'`
                        kill -s 9 $pid
                done

                /sbin/service $service start

                get_server_status $service
                if_running=$?
                if [ "1" == "$if_running" ]
                then
                        if_success="restarted"
                else
                        if_success="not restarted"
                fi

                message="`hostname`: $service is not running! Restarted: $if_success"

                echo $message | mail -s "`hostname`: service is not running" root
        fi
}


function check_process()
{
        process=$1
        if [ "1" == "$DEBUG" ]; then echo "process: "$process; fi

        pid=`pidof $process`
        if [ "" == "$pid" ]
        then
                echo "$process is not running"
                start_process $process
        else
                if [ "1" == "$DEBUG" ]; then echo "process is running, pid: "$pid; fi
        fi
}

function start_process()
{
        process=$1
        if [ "1" == "$DEBUG" ]; then echo "process: "$process; fi

        case $process in
                "searchd" )
                        echo "starting searchd"
                        searchd
                ;;
        esac
}

check_service httpd

check_process searchd

IFS=$ORIGIFS
OFS=$ORIGOFS

