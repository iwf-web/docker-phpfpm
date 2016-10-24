FROM php:5.6-fpm

MAINTAINER Michel Clément <m.clement@iwf.ch>

# Argument variables
ARG GIT_COMMIT
ARG GIT_BRANCH=master
ARG GIT_DIRTY=undefined
ARG BUILD_CREATOR
ARG BUILD_NUMBER
ARG TIMEZONE=Europe/Zurich
ARG SMTP_RELAYHOST=mail.coala.ch
ARG SMTP_MAILNAME=$HOSTNAME.localdomain

# Add labels
LABEL branch=$GIT_BRANCH \
    commit=$GIT_COMMIT \
    dirty=$GIT_DIRTY \
    build-creator=$BUILD_CREATOR \
    build-number=$BUILD_NUMBER

# Set different host due to ip-location redir errors...
RUN sed -i "s/httpredir.debian.org/`curl -s -D - http://httpredir.debian.org/demo/debian/ | awk '/^Link:/ { print $2 }' | sed -e 's@<http://\(.*\)/debian/>;@\1@g'`/" /etc/apt/sources.list

# Install & configure Postfix
RUN DEBIAN_FRONTEND=noninteractive \
    echo "postfix postfix/mailname string '$SMTP_MAILNAME'" | debconf-set-selections && \
    echo "postfix postfix/main_mailer_type string 'Satellite system'" | debconf-set-selections && \
    echo "postfix postfix/relayhost string '$SMTP_RELAYHOST'" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && \
    apt-get install --no-install-recommends -y postfix
RUN DEBIAN_FRONTEND=noninteractive \
    dpkg-reconfigure debconf

# Update System, install base stuff
RUN  DEBIAN_FRONTEND=noninteractive \
     apt-get update && \
     apt-get install --no-install-recommends -y \
     binutils \
     curl \
     git \
     git-core \
     unzip \
     vim \
     wget \
     ruby \
     ruby-dev \
     openssh-client \
     sudo \
     postfix \
     mailutils \
     ssl-cert \
     openssl


# Install base PHP stuff
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && apt-get install -y \
    php5-mysql \
    php5-curl \
    php5-common \
    php5-gd \
    php5-imagick \
    php5-intl \
    php5-dev \
    php5-sqlite \
    #php5-xdebug \
    #php5-memcached \
    \
    #libmemcached-dev \
    libmcrypt-dev \
    libfreetype6-dev \
    libxml2-dev \
    libmagickwand-dev \
    libjpeg62-turbo-dev \
    libpng-dev && \
    \
    docker-php-ext-install pdo pdo_mysql && \
    docker-php-ext-install soap && \
    docker-php-ext-configure gd --with-jpeg-dir=/usr/include/ && \
    docker-php-ext-install gd && \
    docker-php-ext-install iconv mcrypt && \
    docker-php-ext-install exif && \
    docker-php-ext-install zip && \
    \
    pecl install imagick && \
    docker-php-ext-enable imagick && \
    #pecl install memcached  && \
    #docker-php-ext-enable memcached && \
    \
    pecl install zendopcache-7.0.4 && \
    docker-php-ext-enable opcache
    \
    #pecl install xdebug && \
    #docker-php-ext-enable xdebug

# Clean up
RUN apt-get clean \
    && \
    rm -rf /tmp/* /var/tmp/* /usr/share/doc/*

# Remove lists to prevent installations
#RUN rm -rf /var/lib/apt/lists/*

# COPY default php.ini
COPY ./image/php.ini /usr/local/etc/php/conf.d/php.ini
# do we need to copy it to /etc/php5/cli/php.ini as well??

# Set time zone
RUN rm /etc/localtime && \
    ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo date.timezone = \"${TIMEZONE}\" >>/usr/local/etc/php/conf.d/php.ini

# install composer
RUN  curl -sS https://getcomposer.org/installer | php && \
     mv composer.phar /usr/local/bin/composer

# Build base structure
RUN mkdir -p /app

# Set ownerships
#RUN chown -R www-data:www-data /app && \
#    chown -R www-data:www-data /web

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

# Exposed port(s)
EXPOSE 9000

# Start php-fpm
CMD ["php-fpm"]
