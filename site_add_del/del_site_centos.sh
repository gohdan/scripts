#!/bin/sh

# $1 - username


if [[ '' != $1 ]]
then
        echo 'username: '$1

        userdel -fr $1
        groupdel $1

        if [ -e /var/www/html/$1 ]
        then
                echo 'removing /var/www/html/'$1
                rm -rf /var/www/html/$1
        fi

        if [ -e /etc/httpd/vhosts.d/$1.conf ]
        then
                echo "removing /etc/httpd/vhosts.d/$1.conf"
                rm /etc/httpd/vhosts.d/$1.conf
                service httpd restart
        fi

        echo "dropping database "$1
    echo "enter MySQL root password:"
        read mysql_password
    echo "DROP DATABASE IF EXISTS \`$1\`" | mysql -u root -p$mysql_password
    echo "REVOKE ALL PRIVILEGES, GRANT OPTION FROM '$1'" | mysql -u root -p$mysql_password
    echo "DROP USER '$1'" | mysql -u root -p$mysql_password
    echo "REVOKE ALL PRIVILEGES, GRANT OPTION FROM '$1'@'localhost'" | mysql -u root -p$mysql_password
    echo "DROP USER '$1'@'localhost'" | mysql -u root -p$mysql_password

else
        echo 'username is not given'
fi

