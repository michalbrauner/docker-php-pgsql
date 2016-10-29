FROM php:5.6-fpm

RUN apt-get update && apt-get install -y \
        libpq-dev libssl-dev libc-client-dev libkrb5-dev  \
     && docker-php-ext-install pdo pdo_pgsql gettext ftp bcmath \
     && rm -r /var/lib/apt/lists/*

RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl && docker-php-ext-install imap

# iconv, mcrypt, gd
RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng12-dev \
    && docker-php-ext-install -j$(nproc) iconv mcrypt \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd

# xdebug
RUN pecl install xdebug \
    && echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20131226/xdebug.so" >> /usr/local/etc/php/php.ini \
    && echo "xdebug.remote_enable=1" >> /usr/local/etc/php/php.ini \
    && echo "xdebug.remote_mode=req" >> /usr/local/etc/php/php.ini \
    && echo "xdebug.remote_port=9000" >> /usr/local/etc/php/php.ini \
    && echo "xdebug.remote_autostart=1" >> /usr/local/etc/php/php.ini \
    && echo "xdebug.remote_connect_back=0" >> /usr/local/etc/php/php.ini

# git & unzip (to be able to install packages via composer)
RUN apt-get update && apt install -y git unzip

# composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# phpunit
RUN composer global require "phpunit/phpunit"
ENV PATH /root/.composer/vendor/bin:$PATH
RUN ln -s /root/.composer/vendor/bin/phpunit /usr/bin/phpunit

CMD ["php-fpm"]
