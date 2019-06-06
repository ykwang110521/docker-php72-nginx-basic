FROM ubuntu:16.04

# install php 7.2
RUN apt-get update && \
    apt-get upgrade -y --no-install-recommends --no-install-suggests && \
    apt-get install software-properties-common python-software-properties -y --no-install-recommends --no-install-suggests && \
    LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php -y && \
    apt-get update && \
    apt-get install php7.2-fpm php7.2-cli -y --no-install-recommends --no-install-suggests


RUN apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
    nginx \
    ca-certificates \
    gettext \
    mc \
    libmcrypt-dev  \
    libicu-dev \
    libcurl4-openssl-dev \
    mysql-client \
    libldap2-dev \
    libfreetype6-dev \
    libfreetype6 \
    libpng12-dev \
    curl \
    supervisor


# exts
RUN apt-get update && \
    apt-get install -y --no-install-recommends --no-install-suggests \
    php-pear \
    php7.2-mongodb \
    php7.2-curl \
    php7.2-intl \
    php7.2-soap \
    php7.2-xml \
    php-mcrypt \
    php7.2-bcmath \
    php7.2-mysql \
    php7.2-mysqli \
    php7.2-amqp \
    php7.2-mbstring \
    php7.2-ldap \
    php7.2-zip \
    php7.2-iconv \
    php7.2-pdo \
    php7.2-json \
    php7.2-simplexml \
    php7.2-xmlrpc \
    php7.2-gmp \
    php7.2-fileinfo \
    php7.2-sockets \
    php7.2-gd \
    php7.2-redis


# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log \
	&& ln -sf /dev/stderr /var/log/php7.2-fpm.log

RUN rm -f /etc/nginx/sites-enabled/*
COPY nginx/default.conf /etc/nginx/conf.d/default.conf
COPY nginx/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY php-fpm/www.conf /etc/php/7.2/fpm/pool.d/www.conf
COPY php-fpm/php-fpm.conf /etc/php/7.2/fpm/php-fpm.conf
COPY php-fpm/php.ini /etc/php/7.2/fpm/php.ini

# Configure supervisord
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Setup document root
RUN mkdir -p /var/www

# Add application
WORKDIR /var/www
COPY  www/ /var/www


RUN mkdir -p /run/php && touch /run/php/php7.2-fpm.sock && touch /run/php/php7.2-fpm.pid

EXPOSE 80
# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
