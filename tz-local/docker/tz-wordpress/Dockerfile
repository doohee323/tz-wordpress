FROM php:7.2-fpm

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# install php + etc
RUN apt-get update
RUN apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev libonig-dev libgmp-dev libzip-dev libmcrypt-dev \
        gcc make autoconf libc-dev pkg-config \
        git awscli zip unzip \
        curl libcurl4

RUN docker-php-ext-install mysqli
RUN docker-php-ext-install pdo
RUN docker-php-ext-install pdo_mysql

LABEL Name=tz-wordpress

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
#RUN mkdir -p /vagrant
#RUN mkdir -p /vagrant/logs
#ADD ./wordpress /vagrant/wordpress/
#WORKDIR /vagrant/wordpress/

# setup php configure
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini
RUN sed -i 's/upload_max_filesize\s*=.*/upload_max_filesize=40M/g' /usr/local/etc/php/php.ini
RUN sed -i 's/post_max_size\s*=.*/post_max_size=40M/g' /usr/local/etc/php/php.ini
RUN sed -i 's/short_open_tag\s*=.*/short_open_tag=On/g' /usr/local/etc/php/php.ini
RUN sed -i 's/memory_limit\s*=.*/memory_limit=1024M/g' /usr/local/etc/php/php.ini
RUN sed -i 's/display_errors = Off/display_errors = On/g' /usr/local/etc/php/php.ini

#ADD ./wordpress/wp-config.php /vagrant/wordpress/
