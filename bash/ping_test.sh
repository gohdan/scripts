#!/bin/bash

ADDRESS="192.168.0.10"

if ping -c 1 -s 1 -W 1 $ADDRESS
then
    echo "Соединение установлено"
else
    echo "Соединение потеряно"
fi
