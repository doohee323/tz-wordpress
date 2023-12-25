#!/usr/bin/env bash

#git clone -b docker https://github.com/doohee323/tz-wordpress.git
#cd tz-wordpress

sudo wget http://wordpress.org/latest.tar.gz
sudo tar xzvf latest.tar.gz

sudo cp tz-local/docker/tz-wordpress/wp-config.php wordpress/wp-config.php

cd tz-local/docker/
#docker container stop $(docker container ls -a -q) && docker system prune -a -f --volumes
#docker-compose -f docker-compose.yml build --no-cache
#docker-compose -f docker-compose2.yml down
docker-compose -f docker-compose.yml build
docker-compose -f docker-compose.yml up -d
#docker logs docker-nginx-1

curl http://localhost:8080

exit 0

docker exec -it `docker ps | grep tz-wordpress | awk '{print $1}'` bash
docker exec -it `docker ps | grep docker-nginx | awk '{print $1}'` bash

DOCKER_ID=doohee323
DOCKER_PASSWD=xxxx
APP=tz-wordpress
BRANCH=latest
docker login -u="${DOCKER_ID}" -p="${DOCKER_PASSWD}"
TAG="${DOCKER_ID}/${APP}:${BRANCH}"
RMI=`docker images -a | grep ${DOCKER_ID}/${APP} | grep latest | awk '{print $3}'`
echo docker tag ${RMI} ${TAG}
docker tag ${RMI} ${TAG}
docker push ${TAG}

exit 0

SELECT * FROM wp_options WHERE option_name = 'home' OR option_name = 'siteurl';
UPDATE wp_options SET option_value = replace(option_value, 'https://new-nation.church', 'http://34.94.230.37') WHERE option_name = 'home' OR option_name = 'siteurl';
UPDATE wp_posts SET guid = replace(guid, 'https://new-nation.church','http://34.94.230.37');
UPDATE wp_posts SET post_content = replace(post_content, 'https://new-nation.church', 'http://34.94.230.37');
UPDATE wp_postmeta SET meta_value = replace(meta_value,'https://new-nation.church','http://34.94.230.37');


select * from wp_options
WHERE option_name = 'home' OR option_name = 'siteurl';

#newnation /

wget https://getcomposer.org/download/1.8.0/composer.phar -O /usr/local/bin/composer && chmod 755 /usr/local/bin/composer
composer self-update
composer install
#
#curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

exit 0

#https://phoenixnap.com/kb/letsencrypt-docker

cd wordpress
mkdir -p certbot/conf
mkdir -p certbot/www

cd tz-local/docker
docker-compose -f docker-compose-https1.yml build
docker-compose -f docker-compose-https1.yml up

docker-compose -f docker-compose-https1.yml run --rm certbot certonly --webroot \
  --webroot-path /var/www/certbot/ --dry-run -d new-nation.church -d www.new-nation.church

docker-compose -f docker-compose-https1.yml run --rm certbot certonly --webroot \
  --webroot-path /var/www/certbot/ -d new-nation.church -d www.new-nation.church

#docker-compose -f docker-compose-https2.yml build
docker-compose -f docker-compose-https2.yml up

# renew certi
cd /home/ubuntu/tz-wordpress/tz-local/docker
docker-compose -f docker-compose-https1.yml run --rm certbot renew

exit 0

FLUSH PRIVILEGES;

mysql -u root -p

CREATE USER 'wordpressuser'@'%' IDENTIFIED BY 'xxxxx';
GRANT ALL PRIVILEGES ON *.* to 'wordpressuser'@'%';
GRANT ALL PRIVILEGES ON wordpressuser.* to 'wordpressuser'@'%';
GRANT ALL PRIVILEGES ON `%`.* TO wordpressuser@'%';
ALTER USER 'wordpressuser'@'%' IDENTIFIED WITH mysql_native_password BY 'xxxxx';
SHOW GRANTS for wordpressuser;

mysql -u wordpressuser -p
CREATE DATABASE wordpress;

#/usr/bin/mysqldump --user='wordpressuser' --password='xxxxx' -h localhost wordpress > /home/ubuntu/mysql_backup/wordpress-`date +"%Y-%m-%d"`.sql

MYSQL_PASSWORD='xxxxx'
mysql -h 34.94.230.37 -P 3306 -u wordpressuser -p${MYSQL_PASSWORD}
mysql -h 34.94.230.37 -P13306 -u wordpressuser -p${MYSQL_PASSWORD} wordpress < wordpress-2023-11-19.sql

UPDATE wp_options SET option_value = replace(option_value, 'http://new-nation.church', 'https://new-nation.church') WHERE option_name = 'home' OR option_name = 'siteurl';
UPDATE wp_posts SET guid = replace(guid, 'http://new-nation.church','https://new-nation.church');
UPDATE wp_posts SET post_content = replace(post_content, 'http://new-nation.church', 'https://new-nation.church');
UPDATE wp_postmeta SET meta_value = replace(meta_value,'http://new-nation.church','https://new-nation.church');

apt install default-mysql-client -y
MYSQL_PASSWORD='xxxxx'
mysql -h 34.94.230.37 -P 3306 -u wordpressuser -p${MYSQL_PASSWORD}
