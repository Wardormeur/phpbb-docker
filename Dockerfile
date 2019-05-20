# phpBB Dockerfile

FROM php:7.1-apache

# Do a dist-upgrade and install the required packages:
RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get dist-upgrade -y \
  && apt-get install --no-install-recommends --no-install-suggests -y \
    libpng-dev \
    libjpeg-dev \
    imagemagick \
    jq \
    bzip2 \
    mysql-client \
  # Install required PHP extensions:
  && docker-php-ext-configure \
    gd --with-jpeg-dir=/usr/include/ \
  && docker-php-ext-install \
    gd \
    mysqli \
    # pdo \
    pdo_mysql \
    zip \
  # Uninstall obsolete packages:
  && apt-get autoremove -y \
    libpng-dev \
    libjpeg-dev \
  # Remove obsolete files:
  && apt-get clean \
  && rm -rf \
    /tmp/* \
    /usr/share/doc/* \
    /var/cache/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# Enable the Apache Rewrite module:
RUN ln -s /etc/apache2/mods-available/rewrite.load \
  /etc/apache2/mods-enabled/rewrite.load

# Enable the Apache Headers module:
RUN ln -s /etc/apache2/mods-available/headers.load \
  /etc/apache2/mods-enabled/headers.load

RUN a2enmod proxy proxy_http

# Add a custom Apache config:
COPY apache.conf /etc/apache2/conf-enabled/custom.conf

# Add the PHP config file:
COPY php.ini /usr/local/etc/php/

# Add the custom Apache run script
# and a script to download and extract the latest stable phpBB version:
COPY entrypoint.sh /usr/local/bin

# Add the phpBB config file:
COPY config.php /etc/phpBB/config.php
COPY install-config.yml /etc/phpBB/install-config.yml

# install deps
WORKDIR /var/www/html
COPY phpbb /var/www/html

RUN curl --silent --show-error https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

# Debug ext
COPY ext_checker.php /var/www/html/phpBB/ext_checker.php

# Expose the phpBB upload directories as volumes:
VOLUME \
  /var/www/html/phpBB/files \
  /var/www/html/phpBB/store \
  /var/www/html/phpBB/images/avatars/upload

ENV \
  DBHOST=mysql \
  DBPORT= \
  DBNAME=phpbb \
  DBUSER=phpbb \
  DBPASSWD= \
  TABLE_PREFIX=phpbb_ \
  PHPBB_INSTALLED=true \
  AUTO_DB_MIGRATE=false

CMD ["/usr/local/bin/entrypoint.sh"]
