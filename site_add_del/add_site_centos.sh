#!/bin/sh

# $1 - username
# $2 - domainname

VHOSTSDIR=/etc/httpd/vhosts.d/

if [[ '' != $1 ]]
then
        echo "username: "$1

        if [[ '' != $2 ]]
        then
                echo "domainname: "$2

                # === system ===

                passwd=`pwgen 12 1`
                echo "passwd: "$passwd

                useradd -G apache -s /sbin/nologin $1
                usermod -a -G $1 apache
                echo $passwd | passwd $1 --stdin

                # === apache ===

                mkdir /home/$1/www
                mkdir /home/$1/logs
                mkdir /var/www/html/$1
                ln -s /home/$1/www /var/www/html/$1
                ln -s /home/$1/logs /var/www/html/$1

                echo "<html><head><title>$2</title></head><body><p>$2</p></body></html>" > /home/$1/www/index.html

                chown -R $1:$1 /var/www/html/$1
                chown -R $1:$1 /home/$1
                chmod g+rx /home/$1
                vhost=$VHOSTSDIR/$1.conf                                                                                                                                                        [1/42]
                touch $vhost
                echo "<VirtualHost *:80>" >> $vhost
                echo "ServerName "$2 >> $vhost
                echo "ServerAlias www."$2 >> $vhost
                echo "DocumentRoot /var/www/html/$1/www" >> $vhost
                echo "ErrorLog /var/www/html/$1/logs/error.log" >> $vhost
                echo "CustomLog /var/www/html/$1/logs/access.log common" >> $vhost
                echo "<Directory /var/www/html/$1/www>" >> $vhost
                echo "Options Indexes FollowSymLinks" >> $vhost
                echo "</Directory>" >> $vhost
                echo "</VirtualHost>" >> $vhost

                service httpd restart

                # === MySQL ===

                mysqlpasswd=`pwgen 12 1`
                echo "MySQL password: "$mysqlpasswd
                echo "enter MySQL root password:"
                echo "CREATE DATABASE \`$1\`; GRANT ALL ON \`$1\`.* TO '$1'@'localhost' IDENTIFIED BY '$mysqlpasswd'" | mysql -u root -p

                # === summary ===

                echo ''
                echo "=== SUMMARY ==="
                echo "domainname: "$2
                echo ''
                echo "=== FTP ==="
                echo "host: "$2
                echo "user: "$1
                echo "pass: "$passwd
                echo ''
                echo "=== MySQL ==="
                echo "host: localhost"
                echo "base: "$1
                echo "user: "$1
                echo "pass: "$mysqlpasswd
                echo ''
        else
        echo "no domainname given"
        fi
else
        echo "no username given"
fi

