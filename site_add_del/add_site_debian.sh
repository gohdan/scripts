#!/bin/bash

# usage: add_site.sh domain_name ip_address

# to undo settings:
# rm -rf /var/www/domain_name/ ; rm /etc/nginx/sites-enabled/domain_name.conf ; rm /etc/apache2/sites-enabled/domain_name.conf
# also remove unneeded ips from /etc/apache2/mods-enabled/rpaf.conf

if [[ '' != $1 ]]
then
    echo "domain name: "$1

        if [[ '' != $2 ]]
        then
            echo "ip address: "$2

            # prerequisites
            tasksel install web-server
            apt-get install -y nginx nginx-full
            apt-get install -y libapache2-mod-rpaf proftpd apg
            apt-get install -y php
            apt-get install -y curl libcurl3 libcurl3-dev php7.0-curl php7.0-mcrypt

			echo "RequireValidShell off" >> /etc/proftpd/proftpd.conf
			echo "AuthUserFile /etc/proftpd/ftpd.passwd" >> /etc/proftpd/proftpd.conf
			service proftpd restart

			echo "/bin/false" >> /etc/shells

            mkdir -p /var/www/$1/{www,logs,tmp}

            echo "$1" > /var/www/$1/www/index.php

            chown -R www-data:www-data /var/www/$1

            # === nginx ===

            filename=/etc/nginx/sites-enabled/$1.conf
            echo "nginx config: "${filename}

            echo "server {" >> ${filename}
            echo "  server_name $1 www.$1;" >> ${filename}
            echo "  listen $2:80;" >> ${filename}
            echo "  root /var/www/$1/www;" >> ${filename}
            echo "  access_log /var/www/$1/logs/access.log;" >> ${filename}
            echo "  error_log /var/www/$1/logs/error.log;" >> ${filename}

            echo "  location / {" >> ${filename}
            echo "    proxy_pass http://localhost:8080;" >> ${filename}
            echo "    proxy_set_header X-Real-IP \$remote_addr;" >> ${filename}
            echo "    proxy_set_header Host \$host;" >> ${filename}
            echo "    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;" >> ${filename}
            echo "  }" >> ${filename}

            echo "  location ~* .(jpg|jpeg|gif|png|ico|css|js|zip|rar|pdf|txt)$ {" >> ${filename}
            echo "    root /var/www/$1/www;" >> ${filename}
            echo "    error_page 404 = 404;" >> ${filename}
            echo "  }" >> ${filename}

            echo "}" >> ${filename}

            /usr/sbin/service nginx restart

            # === apache ===

            a2enmod rewrite

            filename=/etc/apache2/sites-enabled/$1.conf
            echo "apache config: "${filename}

            echo "<VirtualHost *:8080>" >> ${filename}
            echo "  ServerName $1" >> ${filename}
            echo "  ServerAlias www.$1" >> ${filename}
            echo "  DocumentRoot /var/www/$1/www" >> ${filename}
            echo "  ErrorLog /var/www/$1/logs/error.log" >> ${filename}
            echo "  CustomLog /var/www/$1/logs/access.log common" >> ${filename}
            echo "  <Directory /var/www/$1/www>" >> ${filename}
            echo "    Options Indexes FollowSymLinks" >> ${filename}
            echo "    AllowOverride All" >> ${filename}
            echo "  </Directory>" >> ${filename}
            echo "  php_value upload_tmp_dir \"/var/www/${1}/tmp\"" >> ${filename}
            echo "  php_value session.save_path \"/var/www/${1}/tmp\"" >> ${filename}
            echo "</VirtualHost>" >> ${filename}

            awk -v IP=" $2" '/RPAFproxy_ips/{$0=$0 IP}1' /etc/apache2/mods-enabled/rpaf.conf > /tmp/rpaf.conf
            mv /tmp/rpaf.conf /etc/apache2/mods-enabled/rpaf.conf

			a2enmod remoteip

			echo "<IfModule mod_remoteip.c>" >> /etc/apache2/mods-enabled/remoteip.conf
			echo "      RemoteIPHeader X-Real-IP" >> /etc/apache2/mods-enabled/remoteip.conf
			echo "      RemoteIPInternalProxy 127.0.0.1 ::1 ${2}" >> /etc/apache2/mods-enabled/remoteip.conf
			echo "</IfModule>" >> /etc/apache2/mods-enabled/remoteip.conf

            # FTP

            password=`apg -M SNCL -m 12 -x 12 -n 1`
            echo "FTP user: "$1
            echo "FTP pass: "$password
            echo $password | ftpasswd --passwd --stdin --file=/etc/proftpd/ftpd.passwd --name=$1 --uid=33 --gid=33 --home=/var/www/$1 --shell=/bin/false
        else
            echo "no ip address given"
            echo "usage: add_site.sh domain_name ip_address"
        fi

            # restarting services

			/usr/sbin/service proftpd restart
            /usr/sbin/service nginx restart
            /usr/sbin/service apache2 restart

else
    echo "no domain name given"
    echo "usage: add_site.sh domain_name ip_address"
fi


