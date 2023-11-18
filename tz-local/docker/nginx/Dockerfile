FROM nginx

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt update && apt install -y zip unzip iputils-ping vim net-tools curl wget sudo netcat-traditional

ADD ./tz-local/docker/nginx/nginx.conf /etc/nginx/nginx.conf
ADD ./tz-local/docker/nginx/default.conf /etc/nginx/conf.d/default.conf

ADD ./wordpress /vagrant/wordpress/
WORKDIR /vagrant/wordpress/
