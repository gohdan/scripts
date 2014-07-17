#!/bin/bash

sudo rm /var/named/chroot/var/named/data/named.run
sudo /sbin/service named restart
sudo cp /etc/resolv.conf.local /etc/resolv.conf
sleep 5

sudo /sbin/service squid restart
sudo /sbin/service httpd restart
sudo /sbin/service mysqld restart
sudo /sbin/service dovecot restart
sudo /sbin/service vsftpd restart
sudo /sbin/service spamassassin restart
sudo /sbin/service spamass-milter restart
sudo /sbin/service sendmail restart
sudo /sbin/service ntpd restart
