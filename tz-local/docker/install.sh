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
docker-compose -f docker-compose2.yml build
docker-compose -f docker-compose2.yml up -d
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

UPDATE wp_options SET option_value = replace(option_value, 'https://new-nation.church', 'http://localhost:8080') WHERE option_name = 'home' OR option_name = 'siteurl';
UPDATE wp_posts SET guid = replace(guid, 'https://new-nation.church','http://localhost:8080');
UPDATE wp_posts SET post_content = replace(post_content, 'https://new-nation.church', 'http://localhost:8080');
UPDATE wp_postmeta SET meta_value = replace(meta_value,'https://new-nation.church','http://localhost:8080');

#newnation /

#wget https://getcomposer.org/download/1.8.0/composer.phar -O /usr/local/bin/composer && chmod 755 /usr/local/bin/composer
#composer self-update
#composer install
#
#curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer





