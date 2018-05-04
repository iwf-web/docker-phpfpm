FROM php:7.1-fpm

MAINTAINER Michel Clément <m.clement@iwf.ch>

# Argument variables
ARG GIT_COMMIT
ARG GIT_BRANCH=master
ARG GIT_DIRTY=undefined
ARG BUILD_CREATOR
ARG BUILD_NUMBER
ARG TIMEZONE=Europe/Zurich

ENV DEBIAN_FRONTEND=noninteractive

# Add labels
LABEL io.web-solutions.git-branch=$GIT_BRANCH \
    io.web-solutions.git-commit=$GIT_COMMIT \
    io.web-solutions.git-is-dirty=$GIT_DIRTY \
    io.web-solutions.build-creator=$BUILD_CREATOR \
    io.web-solutions.build-number=$BUILD_NUMBER

# Set different host due to ip-location redir errors...
RUN sed -i "s/httpredir.debian.org/`curl -s -D - http://httpredir.debian.org/demo/debian/ | awk '/^Link:/ { print $2 }' | sed -e 's@<http://\(.*\)/debian/>;@\1@g'`/" /etc/apt/sources.list

# Update System, install base stuff
RUN  apt-get update && \
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
     dnsutils \
     ssl-cert \
     openssl \
     nano \
     supervisor \
     netcat

# Install base PHP stuff
RUN apt-get update && apt-get --no-install-recommends install -y \
    zlib1g-dev \
    libicu-dev \
    g++ \
#    php5-mysql \
#    php5-curl \
#    php5-common \
#    php5-gd \
#    php5-imagick \
#    php5-intl \
#    php5-dev \
    libcurl4-gnutls-dev \
    libsqlite3-dev \
    libfreetype6-dev \
    libxml2-dev \
    libmagickwand-dev \
    libjpeg-dev \
    libjpeg62-turbo-dev \
    libpng-dev && \

    docker-php-ext-install curl && \
    docker-php-ext-install pdo pdo_mysql pdo_sqlite && \
    docker-php-ext-install soap && \
    docker-php-ext-configure gd --with-jpeg-dir --with-png-dir --with-freetype-dir && \
    docker-php-ext-install gd && \
    docker-php-ext-install intl && \
    docker-php-ext-install iconv && \
    docker-php-ext-install exif && \
    docker-php-ext-install zip && \
    \
    pecl install imagick && \
    docker-php-ext-enable imagick && \
    \
    docker-php-ext-install opcache && \
    docker-php-ext-enable opcache

# Clean up
RUN apt-get clean \
    && \
    rm -rf /tmp/* /var/tmp/* /usr/share/doc/*

# Remove lists to prevent installations
# RUN rm -rf /var/lib/apt/lists/*

# COPY default php.ini
COPY ./assets/ /
RUN chmod +x /usr/local/bin/wait-for.sh && \
    chmod +x /usr/local/bin/iwfstartup.sh

# Set time zone
RUN rm /etc/localtime && \
    ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo date.timezone = \"${TIMEZONE}\" >>/usr/local/etc/php/conf.d/php.ini

# set TERM to xterm for bash on 2nd top line
RUN sed -i '2i\'"export TERM=xterm" /etc/bash.bashrc

# install composer
RUN  curl -sS https://getcomposer.org/installer | php && \
     mv composer.phar /usr/local/bin/composer

# Build base structure
RUN mkdir -p /app

# Set environment variables.
ENV HOME /var/www

# Define working directory.
WORKDIR /var/www
RUN     chown -R www-data:www-data /var/www

USER www-data

# Exposed port(s)
EXPOSE 9000

# Start supervisor (see http://supervisord.org)
ENTRYPOINT ["/usr/local/bin/iwfstartup.sh"]
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/iwfsupervisor.conf"]
