FROM php:7-apache
MAINTAINER lionetech <lion@lionetech.com>

RUN apt-get update && apt-get install -y \
    libpq-dev \
    libmemcached-dev \
    curl \
    git \
    supervisor \
    cron \
    libpng12-dev \
    libfreetype6-dev \
    unzip \
    --no-install-recommends \
    && rm -r /var/lib/apt/lists/*

RUN docker-php-ext-configure gd \
    --enable-gd-native-ttf \
    --with-freetype-dir=/usr/include/freetype2

RUN docker-php-ext-install \
    pdo_mysql \
    pdo_pgsql \
    gd \
    zip \
    mbstring

RUN curl -L -o /tmp/memcached.tar.gz "https://github.com/php-memcached-dev/php-memcached/archive/php7.tar.gz" \
    && mkdir -p /usr/src/php/ext/memcached \
    && tar -C /usr/src/php/ext/memcached -zxvf /tmp/memcached.tar.gz --strip 1 \
    && docker-php-ext-configure memcached \
    && docker-php-ext-install memcached \
    && rm /tmp/memcached.tar.gz

RUN pecl install mongodb

RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/supervisor

#调整时区

RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
RUN echo "date.timezone = Asia/Shanghai" >> /etc/php.ini

#安装composer

RUN curl -sS https://getcomposer.org/installer -o composer-setup.php
RUN php composer-setup.php --install-dir=/bin --filename=composer

#配置apache

RUN a2enmod ssl rewrite
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

#安装nodejs
curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo apt-get install -y nodejs
