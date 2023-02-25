#FROM doohee323/tz-ubuntu:latest
FROM php:8.1-fpm

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# install php + etc
RUN apt-get update
RUN apt-get install -y libfreetype6-dev libjpeg62-turbo-dev libpng-dev libonig-dev libgmp-dev libzip-dev libmcrypt-dev \
        gcc make autoconf libc-dev pkg-config \
        git awscli zip unzip \
        curl libcurl4
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install -j$(nproc) gd

# enable docker-php extensions
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install gmp
RUN docker-php-ext-install iconv
RUN docker-php-ext-install mysqli
RUN docker-php-ext-install pdo
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install exif

# install zip
RUN docker-php-ext-install zip
# install mcrypt

RUN pecl install mcrypt \
    && docker-php-ext-enable mcrypt \

# install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

LABEL Name=tz-wordpress

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN mkdir -p /home/ubuntu
RUN mkdir -p /home/ubuntu/logs
ADD ./wordpress /home/ubuntu/wordpress/
WORKDIR /home/ubuntu/wordpress/

# setup php configure
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini
RUN sed -i 's/upload_max_filesize\s*=.*/upload_max_filesize=40M/g' /usr/local/etc/php/php.ini
RUN sed -i 's/post_max_size\s*=.*/post_max_size=40M/g' /usr/local/etc/php/php.ini
RUN sed -i 's/short_open_tag\s*=.*/short_open_tag=On/g' /usr/local/etc/php/php.ini
RUN sed -i 's/memory_limit\s*=.*/memory_limit=1024M/g' /usr/local/etc/php/php.ini
RUN sed -i 's/display_errors = Off/display_errors = On/g' /usr/local/etc/php/php.ini

#ADD ./wordpress/wp-config.php /home/ubuntu/wordpress/
