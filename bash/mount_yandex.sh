#!/bin/sh
mount -t davfs https://webdav.yandex.ru /home/gohdan/yandex/ -o uid=1000,gid=1000

#!/usr/bin/expect
#spawn mount.davfs https://webdav.yandex.ru /home/gohdan/yandex
#expect "Username:"
#send "USERNAME@yandex.ru\r"
#expect "Password:"
#send "PASS\r"
#expect eof

