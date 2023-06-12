#!/usr/bin/env bash

# bash /home/ubuntu/resources/youthwp.sh

#set -x

export USER=ubuntu
export PROJ_NAME=youthwp
export HOME_DIR=/home/$USER
export PROJ_DIR=/home/ubuntu
export SRC_DIR=/home/ubuntu/resources  # for home/ubuntu

sudo sh -c "echo '' >> $HOME_DIR/.bashrc"
sudo sh -c "echo 'export PATH=$PATH:.' >> $HOME_DIR/.bashrc"
sudo sh -c "echo 'export HOME_DIR='$HOME_DIR >> $HOME_DIR/.bashrc"
sudo sh -c "echo 'export SRC_DIR='$SRC_DIR >> $HOME_DIR/.bashrc"
sudo sh -c "echo 'export PROJ_DIR='$PROJ_DIR >> $HOME_DIR/.bashrc"
source $HOME_DIR/.bashrc

### [install mysql] ############################################################################################################
sudo apt-get purge mysql-server-8.0 -y
sudo rm -Rf /var/lib/mysql
sudo rm -Rf /etc/mysql/mysql.conf.d/mysqld.cnf
echo "mysql-server-8.0 mysql-server/root_password password passwd123" | sudo debconf-set-selections
echo "mysql-server-8.0 mysql-server/root_password_again password passwd123" | sudo debconf-set-selections
sudo apt-get install mysql-server-8.0 -y
mysql -u root -ppasswd123 -e "SHOW databases;"

if [ -f "/etc/mysql/mysql.conf.d/mysqld.cnf" ]; then
    sudo sed -i "s/bind-address/#bind-address/g" /etc/mysql/mysql.conf.d/mysqld.cnf
    sudo sed -i "s/mysqlx-#bind-address/mysqlx-bind-address/g" /etc/mysql/mysql.conf.d/mysqld.cnf
    sudo sed -i "s/127.0.0.1/0.0.0.0/g" /etc/mysql/mysql.conf.d/mysqld.cnf
fi

sleep 10
#sudo mysql_secure_installation
sudo bash /home/ubuntu/resources/mysql_secure_installation.sh
mysql -u root -ppasswd123 -e "SHOW databases;"

#sudo mysql -u root -ppasswd123 -e \
#"use mysql; \
#SET GLOBAL validate_password.policy=LOW; \
#CREATE USER 'root'@'localhost' IDENTIFIED BY 'passwd123'; \
#GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost'; \
#FLUSH PRIVILEGES; \
#"

sudo mysql -u root -ppasswd123 -e \
"CREATE DATABASE youthwp; \
"
sleep 1
sudo mysql -u root -ppasswd123 -e \
"install plugin validate_password soname 'validate_password.so'; \
select plugin_name, plugin_status from information_schema.plugins where plugin_name like 'validate%'; \
SET GLOBAL validate_password_check_user_name=OFF; \
SET GLOBAL validate_password_policy=LOW; \
SET GLOBAL validate_password_mixed_case_count=0; \
SET GLOBAL validate_password_special_char_count=0; \
CREATE USER youthwpuser@localhost IDENTIFIED BY 'passwd123'; \
GRANT ALL PRIVILEGES ON *.* TO youthwpuser@localhost; \
CREATE USER youthwpuser@'%' IDENTIFIED BY 'passwd123'; \
GRANT ALL PRIVILEGES ON *.* TO youthwpuser@'%'; \
SET SQL_SAFE_UPDATES=0; \
FLUSH PRIVILEGES; \
"
#mysql> SHOW VARIABLES LIKE 'validate_password%';

sudo service mysql stop
sudo service mysql start
#sudo service mysql status
tail /var/log/mysql/error.log
mysql -u youthwpuser -ppasswd123 -e "SHOW databases;"

### [install php] ############################################################################################################
sudo apt-get install software-properties-common -y
sudo add-apt-repository ppa:ondrej/php -y
#sudo apt-get purge php7.4 -y
sudo apt-get update && sudo apt-get install php7.4 -y
#sudo apt-get install php7.4 libapache2-mod-php7.4 php7.4-common php7.4-mbstring php7.4-xmlrpc php7.4-soap php7.4-gd -y
sudo apt-get install php7.4-fpm php7.4-xml php7.4-intl php7.4-mysql php7.4-cli php7.4-mcrypt php7.4-zip php7.4-curl -y
#sudo apt-get install php-mysql -y
#sudo apt-get install libapache2-mod-php7.4 -y

sudo apt install libapache2-mod-php7.4 php-mysql php-xml php7.4-gd php7.4-mbstring php7.4-zip -y
sudo a2enmod rewrite

#sudo sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/g" /etc/php/7.4/fpm/php.ini
#sudo sed -i "s/;error_log = php_errors.log/error_log = php_errors.log/g" /etc/php/7.4/fpm/php.ini
#sudo sed -i "s/upload_max_filesize = 2M/upload_max_filesize = 200M/g" /etc/php/7.4/fpm/php.ini
#sudo sed -i "s/post_max_size = 8M/post_max_size = 200M/g" /etc/php/7.4/fpm/php.ini
#sudo sed -i "s/max_execution_time = 30/max_execution_time = 360/g" /etc/php/7.4/fpm/php.ini
#sudo sed -i "s/max_input_time = 300/max_input_time = 24000/g" /etc/php/7.4/fpm/php.ini
#sudo sed -i "s/memory_limit = 128MB/memory_limit = 2048M/g" /etc/php/7.4/fpm/php.ini
sudo service php7.4-fpm stop

### [install apache2] ############################################################################################################
sudo apt-get purge apache2 -y
sudo apt-get install apache2 -y
sudo sh -c "echo '' >> /etc/apache2/apache2.conf"
sudo sh -c "echo '<Directory /var/www/youthwp/>' >> /etc/apache2/apache2.conf"
sudo sh -c "echo '    AllowOverride All' >> /etc/apache2/apache2.conf"
sudo sh -c "echo '</Directory>' >> /etc/apache2/apache2.conf"
sudo sh -c "echo '' >> /etc/apache2/apache2.conf"

cat <<EOT > /etc/apache2/sites-available/youthwp.conf

<VirtualHost *:80>
    ServerAdmin admin@local.com
    DocumentRoot /var/www/youthwp/
    ServerName youthwp.new-nation.church
    ServerAlias youthwp.new-nation.church

    <Directory /var/www/youthwp/>
      Options Indexes FollowSymLinks
      AllowOverride All
      Require all granted
    </Directory>

    ErrorLog /var/log/apache2/error.log
    CustomLog /var/log/apache2/access.log combined
</VirtualHost>

EOT

rm -Rf /etc/apache2/sites-enabled/000-default.conf
ln -s /etc/apache2/sites-available/youthwp.conf /etc/apache2/sites-enabled/youthwp.conf

rm -rf /var/www/youthwp/index.html

sudo apt reinstall apache2 libapache2-mod-wsgi -y
cd /etc/apache2/sites-enabled
sudo a2ensite youthwp.conf
sudo a2enmod rewrite
sudo a2dismod mpm_event
sudo systemctl restart apache2
sudo a2enmod mpm_prefork
sudo systemctl restart apache2
sudo a2enmod php7.4
sudo systemctl restart apache2

### [open firewalls] ############################################################################################################

### [install wordpress] ############################################################################################################
sudo mkdir -p $PROJ_DIR
cd $PROJ_DIR
rm -Rf latest.tar.gz
sudo wget http://wordpress.org/latest.tar.gz
sudo mkdir -p tmp && sudo mv latest.tar.gz tmp && cd tmp && sudo tar xzvf latest.tar.gz && sudo mv wordpress /home/ubuntu/youthwp
sudo chown -Rf ubuntu:ubuntu wordpress
sudo chown -Rf ubuntu:ubuntu youthwp
sudo apt-get install php7.4-gd -y
sudo apt-get install libssh2-php -y

cd $PROJ_DIR/youthwp
sudo cp wp-config-sample.php wp-config.php

sudo sed -i "s/database_name_here/youthwp/g" $PROJ_DIR/youthwp/wp-config.php
sudo sed -i "s/username_here/youthwpuser/g" $PROJ_DIR/youthwp/wp-config.php
sudo sed -i "s/password_here/passwd123/g" $PROJ_DIR/youthwp/wp-config.php

sudo rsync -avP $PROJ_DIR/youthwp/ /var/www/youthwp/
cat <(crontab -l) <(echo "* * * * * sudo rsync -avP $PROJ_DIR/youthwp/ /var/www/youthwp/ && sudo chown -Rf www-data:www-data /var/www/youthwp") | crontab -
cat <(crontab -l) <(echo "* * * * * cd /var/www/youthwp/wp-content/uploads; sudo find . -name \*.mp3 -exec cp {} /var/www/youthwp/pod \;") | crontab -

sudo mkdir -p $PROJ_DIR/youthwp
#sudo userdel www-data
#sudo useradd -c "www-data" -m -d $PROJ_DIR/youthwp/ -s /bin/bash -G sudo www-data
sudo usermod -a -G www-data www-data
sudo usermod --home $PROJ_DIR/youthwp/ www-data
echo -e "www-data\nwww-data" | sudo passwd www-data

cat <<EOT > /var/www/youthwp/.htaccess
# BEGIN WordPress
php_value post_max_size 100M
php_value upload_max_filesize 100M
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>

# END WordPress
EOT

sudo chown -R www-data:www-data /var/www/youthwp/
sudo rm -rf /var/www/youthwp/index.html

### [install ftp] ############################################################################################################
sudo apt-get install vsftpd -y
sudo sed -i "s/anonymous_enable=YES/anonymous_enable=NO/g" /etc/vsftpd.conf
sudo sed -i "s/local_enable=NO/local_enable=YES/g" /etc/vsftpd.conf
sudo sed -i "s/#write_enable=YES/write_enable=YES/g" /etc/vsftpd.conf
sudo sed -i "s/pam_service_name=vsftpd/pam_service_name=ftp/g" /etc/vsftpd.conf
sudo sh -c "echo www-data >> /etc/ftpusers"

### [install s3] ############################################################################################################
sudo mkdir -p /var/www/youthwp/wp-content/uploads
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

    sudo s3fs topzone /var/www/youthwp/wp-content/uploads -o nonempty -o allow_other
    # sudo s3fs topzone /var/www/youthwp/wp-content/uploads -o passwd_file=/etc/passwd-s3fs -d -d -f -o f2 -o curldbg -o nonempty
    # sudo umount /var/www/youthwp/wp-content/uploads
    # sudo fusermount -u /var/www/youthwp/wp-content/uploads
    # cf. s3fs topzone /var/www/youthwp/wp-content/uploads -o passwd_file=/etc/passwd-s3fs -d -d -f -o f2 -o curldbg
    #sudo echo "topzone /var/www/youthwp/wp-content/uploads fuse.s3fs _netdev,allow_other,dbglevel=dbg,curldbg 0 0" >> /etc/fstab
    sudo echo "topzone /var/www/youthwp/wp-content/uploads fuse.s3fs _netdev,allow_other,dbglevel=dbg,curldbg 0 0" >> /etc/fstab
elif [ $1 == "gcp" ];then
	echo "Not ready!!!"
else
    chown -Rf www-data:www-data /var/www/youthwp/wp-content/uploads
fi

### [start services] ############################################################################################################

sudo service mysql restart
#mysql -h localhost -P 3306 -u root -p

sudo service vsftpd restart
sudo service php7.4-fpm restart
sudo service apache2 restart

#curl http://192.168.82.170

### [install wp-cli ] ############################################################################################################

cd $HOME_DIR

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
php wp-cli.phar --info
sudo chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

exit 0


#vi /etc/php/7.4/fpm/php.ini
display_errors = On
display_startup_errors = On
log_errors = On
error_reporting = E_ALL
display_errors = On

sudo service php7.4-fpm restart
#tail -f /var/log/syslog

### [https ] ############################################################################################################
sudo apt install certbot python3-certbot-apache -y

# certbot-auto delete
# service apache2 restart

certbot run --non-interactive --agree-tos \
  --no-eff-email \
  --redirect \
  --email 'doohee323@gmail.com' \
  --installer apache \
  --domains "youthwp.new-nation.church"

#crontab -e
#0,10 0 * * *   /root/certbot-auto renew --quiet --no-self-upgrade

### [open firewalls] ############################################################################################################
#sudo ufw allow "Nginx Full"
#sudo iptables -I INPUT -p tcp --dport 21 -j ACCEPT
#sudo iptables -I INPUT -p tcp --dport 22 -j ACCEPT
#sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT
#sudo iptables -I INPUT -p tcp --dport 443 -j ACCEPT
#sudo iptables -I INPUT -p tcp --dport 3306 -j ACCEPT
#sudo service iptables save
#sudo service iptables restart


mysql --user='youthwpuser'  -h localhost

Jesus019!