#!/usr/bin/env bash

#cd /Volumes/workspace/tz/tz-wordpress/tz-local/tz-ubuntu
#set -x

docker container stop $(docker container ls -a -q) && docker system prune -a -f --volumes
#docker-compose -f docker-compose.yml build --no-cache
docker-compose -f docker-compose.yml build
docker-compose -f docker-compose.yml up -d
#docker-compose -f docker-compose.yml down
#docker logs docker-nginx-1

exit 0

DOCKER_ID=doohee323
DOCKER_PASSWD=xxxxx
APP=tz-wordpress
BRANCH=latest
docker login -u="${DOCKER_ID}" -p="${DOCKER_PASSWD}"
TAG="${DOCKER_ID}/${APP}:${BRANCH}"
echo "######### ${TAG} ##############"
RMI=`docker images -a | grep ${DOCKER_ID}/${APP} | grep latest | awk '{print $3}'`
echo docker tag ${RMI} ${TAG}
docker tag ${RMI} ${TAG}
docker push ${TAG}
