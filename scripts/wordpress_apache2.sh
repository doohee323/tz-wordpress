#!/usr/bin/env bash

set -x

export USER=vagrant  # for vagrant
export PROJ_NAME=wordpress
export HOME_DIR=/home/$USER
export PROJ_DIR=/vagrant
export SRC_DIR=/vagrant/resources  # for vagrant

sudo sh -c "echo '' >> $HOME_DIR/.bashrc"
sudo sh -c "echo 'export PATH=$PATH:.' >> $HOME_DIR/.bashrc"
sudo sh -c "echo 'export HOME_DIR='$HOME_DIR >> $HOME_DIR/.bashrc"
sudo sh -c "echo 'export SRC_DIR='$SRC_DIR >> $HOME_DIR/.bashrc"
source $HOME_DIR/.bashrc

sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:ondrej/php -y
sudo add-apt-repository ppa:ondrej/mysql-5.6 -y
sudo apt-get update

### [install mysql] ############################################################################################################
echo "mysql-server-5.6 mysql-server/root_password password passwd123" | sudo debconf-set-selections
echo "mysql-server-5.6 mysql-server/root_password_again password passwd123" | sudo debconf-set-selections
sudo apt-get install mysql-server-5.6 -y

if [ -f "/etc/mysql/my.cnf" ];then
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

### [install php] ############################################################################################################
sudo apt-get install php7.1 libapache2-mod-php7.1 php7.1-common php7.1-mbstring php7.1-xmlrpc php7.1-soap php7.1-gd -y
sudo apt-get install php7.1-fpm php7.1-xml php7.1-intl php7.1-mysql php7.1-cli php7.1-mcrypt php7.1-zip php7.1-curl -y
sudo apt-get install libapache2-mod-php7.1 -y

sudo sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.1/fpm/php.ini
sudo sed -i "s/;error_log = php_errors.log/error_log = php_errors.log/g" /etc/php/7.1/fpm/php.ini
sudo sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 200M/g" /etc/php/7.1/fpm/php.ini
sudo sed -i "s/post_max_size = 8M/post_max_size = 200M/g" /etc/php/7.1/fpm/php.ini
sudo sed -i "s/max_execution_time = 30/max_execution_time = 360/g" /etc/php/7.1/fpm/php.ini
sudo sed -i "s/max_input_time = 300/max_input_time = 24000/g" /etc/php/7.1/fpm/php.ini
sudo sed -i "s/memory_limit = 128MB/memory_limit = 2048M/g" /etc/php/7.1/fpm/php.ini
sudo service php7.1-fpm stop 

### [install apache2] ############################################################################################################
apt-get install apache2 -y
sudo sh -c "echo '' >> /etc/apache2/apache2.conf"
sudo sh -c "echo '<Directory /var/www/html/>' >> /etc/apache2/apache2.conf"
sudo sh -c "echo '    AllowOverride All' >> /etc/apache2/apache2.conf"
sudo sh -c "echo '</Directory>' >> /etc/apache2/apache2.conf"
sudo sh -c "echo '' >> /etc/apache2/apache2.conf"

cat <<EOT > /etc/apache2/sites-available/wordpress.conf

<VirtualHost *:80>
     ServerAdmin admin@local.com
     DocumentRoot /var/www/html/
     ServerName local.com
     ServerAlias vm.local.com

     <Directory /var/www/html/>
        Options +FollowSymlinks
        AllowOverride All
        Require all granted
     </Directory>

     ErrorLog /var/log/error.log
     CustomLog /var/log/access.log combined
</VirtualHost>

EOT

rm -Rf /etc/apache2/sites-enabled/000-default.conf
ln -s /etc/apache2/sites-available/wordpress.conf /etc/apache2/sites-enabled/wordpress.conf

rm -rf /var/www/html/index.html

sudo a2ensite wordpress.conf
sudo a2enmod rewrite
sudo a2enmod php7.1

service apache2 restart

### [open firewalls] ############################################################################################################
sudo ufw allow "Nginx Full"
sudo iptables -I INPUT -p tcp --dport 21 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 443 -j ACCEPT
sudo iptables -I INPUT -p tcp --dport 3306 -j ACCEPT
sudo service iptables save
sudo service iptables restart

### [install wordpress] ############################################################################################################
su - $USER

sudo mkdir -p $PROJ_DIR
cd $PROJ_DIR
rm -Rf latest.tar.gz
sudo wget http://wordpress.org/latest.tar.gz
sudo tar xzvf latest.tar.gz
sudo apt-get install php5-gd libssh2-php -y

cd $PROJ_DIR/wordpress
sudo cp wp-config-sample.php wp-config.php

sudo sed -i "s/database_name_here/wordpress/g" $PROJ_DIR/wordpress/wp-config.php
sudo sed -i "s/username_here/wordpressuser/g" $PROJ_DIR/wordpress/wp-config.php
sudo sed -i "s/password_here/passwd123/g" $PROJ_DIR/wordpress/wp-config.php

sudo rsync -avP $PROJ_DIR/wordpress/ /var/www/html/
cat <(crontab -l) <(echo "* * * * * sudo rsync -avP $PROJ_DIR/wordpress/ /var/www/html/ && sudo chown -Rf www-data:www-data /var/www/html") | crontab -

sudo mkdir -p $PROJ_DIR/wordpress
#sudo userdel www-data
#sudo useradd -c "www-data" -m -d $PROJ_DIR/wordpress/ -s /bin/bash -G sudo www-data
sudo usermod -a -G www-data www-data
sudo usermod --home $PROJ_DIR/wordpress/ www-data
echo -e "www-data\nwww-data" | sudo passwd www-data

sudo chown -R www-data:www-data /var/www/html/

### [install ftp] ############################################################################################################
sudo apt-get install vsftpd -y
sudo sed -i "s/anonymous_enable=YES/anonymous_enable=NO/g" /etc/vsftpd.conf
sudo sed -i "s/local_enable=NO/local_enable=YES/g" /etc/vsftpd.conf
sudo sed -i "s/#write_enable=YES/write_enable=YES/g" /etc/vsftpd.conf
sudo sed -i "s/pam_service_name=vsftpd/pam_service_name=ftp/g" /etc/vsftpd.conf
sudo sh -c "echo www-data >> /etc/ftpusers"

### [install s3] ############################################################################################################
sudo mkdir -p /var/www/html/wp-content/uploads
if [ $1 == "aws" ];then
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
    
    sudo s3fs topzone /var/www/html/wp-content/uploads -o nonempty -o allow_other 
    # sudo s3fs topzone /var/www/html/wp-content/uploads -o passwd_file=/etc/passwd-s3fs -d -d -f -o f2 -o curldbg -o nonempty 
    # sudo umount /var/www/html/wp-content/uploads
    # sudo fusermount -u /var/www/html/wp-content/uploads
    # cf. s3fs topzone /var/www/html/wp-content/uploads -o passwd_file=/etc/passwd-s3fs -d -d -f -o f2 -o curldbg
    #sudo echo "topzone /var/www/html/wp-content/uploads fuse.s3fs _netdev,allow_other,dbglevel=dbg,curldbg 0 0" >> /etc/fstab
    sudo echo "topzone /var/www/html/wp-content/uploads fuse.s3fs _netdev,allow_other,dbglevel=dbg,curldbg 0 0" >> /etc/fstab
elif [ $1 == "gcp" ];then
	echo "Not ready!!!"
else 
    chown -Rf www-data:www-data /var/www/html/wp-content/uploads
fi

### [start services] ############################################################################################################

sudo /etc/init.d/mysql restart  
#mysql -h localhost -P 3306 -u root -p

sudo service vsftpd restart
sudo service php7.1-fpm restart

#curl http://192.168.82.170

### [install wp-cli ] ############################################################################################################

cd $HOME_DIR

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
php wp-cli.phar --info
sudo chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

exit 0


#vi /etc/php/7.1/fpm/php.ini
display_errors = On
display_startup_errors = On
log_errors = On
error_reporting = E_ALL
display_errors = On

sudo service php7.1-fpm restart
#tail -f /var/log/syslog
