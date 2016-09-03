#!/usr/bin/env bash

set -x

export USER=vagrant  # for vagrant
export PROJ_NAME=wordpress
export PROJ_DIR=/home/$USER
export SRC_DIR=/vagrant/resources  # for vagrant

sudo sh -c "echo '' >> $PROJ_DIR/.bashrc"
sudo sh -c "echo 'export PATH=$PATH:.' >> $PROJ_DIR/.bashrc"
sudo sh -c "echo 'export PROJ_DIR='$PROJ_DIR >> $PROJ_DIR/.bashrc"
sudo sh -c "echo 'export SRC_DIR='$SRC_DIR >> $PROJ_DIR/.bashrc"
source $PROJ_DIR/.bashrc

sudo add-apt-repository ppa:ondrej/php -y
sudo apt-get update

### [install nginx] ############################################################################################################
sudo apt-get install nginx -y

sudo cp $SRC_DIR/nginx/nginx.conf /etc/nginx/nginx.conf
sudo cp -Rf $SRC_DIR/nginx/default /etc/nginx/sites-enabled
sudo service nginx stop
sudo nginx -s stop
sudo nginx
# curl http://127.0.0.1:80

### [install mysql] ############################################################################################################
echo "mysql-server-5.6 mysql-server/root_password password passwd123" | sudo debconf-set-selections
echo "mysql-server-5.6 mysql-server/root_password_again password passwd123" | sudo debconf-set-selections
sudo apt-get install mysql-server-5.6 -y

if [ -f "/etc/mysql/my.cnf" ]
then
	sudo sed -i "s/bind-address/#bind-address/g" /etc/mysql/my.cnf
else
	sudo sed -i "s/bind-address/#bind-address/g" /etc/mysql/mysql.conf.d/mysqld.cnf
fi

sudo mysql -u root -ppasswd123 -e \
"use mysql; \
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'passwd123'; \
FLUSH PRIVILEGES; \
"
sudo mysql -u root -ppasswd123 -e \
"CREATE DATABASE wordpress; \
CREATE USER wordpressuser@localhost; \
SET PASSWORD FOR wordpressuser@localhost= PASSWORD('passwd123'); \
GRANT ALL PRIVILEGES ON wordpress.* TO wordpressuser@localhost IDENTIFIED BY 'passwd123'; \
FLUSH PRIVILEGES; \
"

sudo /etc/init.d/mysql restart  
#mysql -h localhost -P 3306 -u root -p

### [install php] ############################################################################################################
sudo apt-get install php7.0-fpm -y
sudo apt-get install php7.0-mysql -y
sudo sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/;error_log = php_errors.log/error_log = php_errors.log/g" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 200M/g" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/post_max_size = 8M/post_max_size = 200M/g" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/max_execution_time = 300/max_execution_time = 24000/g" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/max_input_time = 300/max_input_time = 24000/g" /etc/php/7.0/fpm/php.ini
sudo sed -i "s/memory_limit = 128MB/memory_limit = 2048M/g" /etc/php/7.0/fpm/php.ini

sudo service php7.0-fpm restart

### [open firewalls] ############################################################################################################
ufw allow "Nginx Full"
sudo iptables -I INPUT -p tcp --dport 21 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 3306 -j ACCEPT
sudo service iptables save
sudo service iptables restart

### [install wordpress] ############################################################################################################
su - $USER

cd $PROJ_DIR
wget http://wordpress.org/latest.tar.gz
tar xzvf latest.tar.gz
apt-get install php5-gd libssh2-php -y

cd $PROJ_DIR/wordpress
cp wp-config-sample.php wp-config.php

sed -i "s/database_name_here/wordpress/g" $PROJ_DIR/wordpress/wp-config.php
sed -i "s/username_here/wordpressuser/g" $PROJ_DIR/wordpress/wp-config.php
sed -i "s/password_here/passwd123/g" $PROJ_DIR/wordpress/wp-config.php

sudo mkdir -p /vagrant
sudo rsync -avP $PROJ_DIR/wordpress/ /vagrant/wordpress/

sudo usermod -a -G www-data www-data
sudo chown -R www-data:www-data /vagrant/wordpress/

#curl http://192.168.82.170

### [install ftp] ############################################################################################################
apt-get install vsftpd
sed -i "s/anonymous_enable=YES/anonymous_enable=NO/g" /etc/vsftpd.conf
sed -i "s/local_enable=NO/local_enable=YES/g" /etc/vsftpd.conf
sed -i "s/#write_enable=YES/write_enable=YES/g" /etc/vsftpd.conf
sed -i "s/pam_service_name=vsftpd/pam_service_name=ftp/g" /etc/vsftpd.conf
sudo sh -c "echo www-data >> /etc/ftpusers"

#useradd -g www-data -d /home/www-data -s /bin/bsh -m xxxxxx
service vsftpd restart

### [install s3] ############################################################################################################
sudo mkdir -p /vagrant/wordpress/wp-content/uploads
if [ $1 == "aws" ]
then
	cd
	sudo apt-get install automake autotools-dev g++ git libcurl4-gnutls-dev libfuse-dev libssl-dev libxml2-dev make pkg-config -y
	git clone https://github.com/s3fs-fuse/s3fs-fuse.git
	cd s3fs-fuse
	./autogen.sh
	./configure
	make
	sudo make install
	
	sudo sh -c "echo $AWS_KEY > /etc/passwd-s3fs"
	sudo chmod 600 /etc/passwd-s3fs
	
	sudo s3fs topzone /vagrant/wordpress/wp-content/uploads -o nonempty -o allow_other 
	# sudo s3fs topzone /vagrant/wordpress/wp-content/uploads -o passwd_file=/etc/passwd-s3fs -d -d -f -o f2 -o curldbg -o nonempty 
	# sudo umount /vagrant/wordpress/wp-content/uploads
	# sudo fusermount -u /vagrant/wordpress/wp-content/uploads
	# cf. s3fs topzone /vagrant/wordpress/wp-content/uploads -o passwd_file=/etc/passwd-s3fs -d -d -f -o f2 -o curldbg
	sudo echo "topzone /vagrant/wordpress/wp-content/uploads fuse.s3fs _netdev,allow_other,dbglevel=dbg,curldbg 0 0" >> /etc/fstab
else 
	chown -Rf www-data:www-data /vagrant/wordpress/wp-content/uploads
if

exit 0
