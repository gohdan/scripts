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

        response=`/usr/bin/systemctl status $service`
        status=`echo $?`

        if [ "1" == "$DEBUG" ]; then echo "responce: $response"; fi
        if [ "1" == "$DEBUG" ]; then echo "status: $status"; fi

        if_running="0"
        if [ "0" == "$status" ]
                then
                        if_running="1"
                fi

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

                restart=`/usr/bin/systemctl restart $service`

                get_server_status $service
                if_running=$?
                if [ "1" == "$if_running" ]
                then
                        if_success="restarted"
                else
                        if_success="not restarted"
                fi
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

