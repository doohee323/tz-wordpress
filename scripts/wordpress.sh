#!/usr/bin/env bash

set -x

export PROJ_NAME=wordpress
export PROJ_DIR=/home/vagrant
export SRC_DIR=/vagrant/resources

echo '' >> $PROJ_DIR/.bashrc
echo 'export PATH=$PATH:.' >> $PROJ_DIR/.bashrc
echo 'export PROJ_DIR='$PROJ_DIR >> $PROJ_DIR/.bashrc
echo 'export SRC_DIR='$SRC_DIR >> $PROJ_DIR/.bashrc
source $PROJ_DIR/.bashrc

sudo add-apt-repository ppa:ondrej/php -y
sudo apt-get update

### [install nginx] ############################################################################################################
sudo apt-get install nginx -y

sudo cp $SRC_DIR/nginx/nginx.conf /etc/nginx/nginx.conf
cp -Rf $SRC_DIR/nginx/default /etc/nginx/sites-enabled
sudo nginx -s stop
sudo nginx
# curl http://127.0.0.1:80

### [install mysql] ############################################################################################################
sudo echo "mysql-server-5.6 mysql-server/root_password password 971097" | sudo debconf-set-selections
sudo echo "mysql-server-5.6 mysql-server/root_password_again password 971097" | sudo debconf-set-selections
sudo apt-get install mysql-server-5.6 -y

if [ -f "/etc/mysql/my.cnf" ]
then
	sudo sed -i "s/bind-address/#bind-address/g" /etc/mysql/my.cnf
else
	sudo sed -i "s/bind-address/#bind-address/g" /etc/mysql/mysql.conf.d/mysqld.cnf
fi

sudo mysql -u root -p971097 -e \
"use mysql; \
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '971097'; \
FLUSH PRIVILEGES; \
"
sudo mysql -u root -p971097 -e \
"CREATE DATABASE wordpress; \
CREATE USER wordpressuser@localhost; \
SET PASSWORD FOR wordpressuser@localhost= PASSWORD('971097'); \
GRANT ALL PRIVILEGES ON wordpress.* TO wordpressuser@localhost IDENTIFIED BY '971097'; \
FLUSH PRIVILEGES; \
"

sudo /etc/init.d/mysql restart  
#mysql -h 45.33.35.145 -P 3306 -u root -p

### [install php] ############################################################################################################
sudo apt-get install php7.0-fpm -y
sudo apt-get install php7.0-mysql -y
sudo sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.0/fpm/php.ini

sudo service php7.0-fpm restart

### [open firewalls] ############################################################################################################
ufw allow "Nginx Full"
sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 3306 -j ACCEPT
sudo service iptables save
sudo service iptables restart

### [install wordpress] ############################################################################################################
su - vagrant

cd $PROJ_DIR
wget http://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
apt-get install php5-gd libssh2-php -y

cd $PROJ_DIR/wordpress
cp wp-config-sample.php wp-config.php

sed -i "s/database_name_here/wordpress/g" $PROJ_DIR/wordpress/wp-config.php
sed -i "s/username_here/wordpressuser/g" $PROJ_DIR/wordpress/wp-config.php
sed -i "s/password_here/971097/g" $PROJ_DIR/wordpress/wp-config.php

sudo rsync -avP $PROJ_DIR/wordpress/ /usr/share/nginx/html/

cd /usr/share/nginx
sudo chown -R www-data:www-data html/
sudo usermod -a -G www-data www-data

#curl http://192.168.82.170

exit 0
