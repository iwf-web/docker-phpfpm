FROM php:7.4-fpm-buster

MAINTAINER Michel Clément <m.clement@iwf.ch>, Jens Hassler <j.hassler@iwf.ch>

# Argument variables
ARG GIT_COMMIT
ARG GIT_BRANCH=master
ARG GIT_DIRTY=undefined
ARG BUILD_CREATOR
ARG BUILD_NUMBER
ARG TIMEZONE=Europe/Zurich

ENV DEBIAN_FRONTEND=noninteractive

# this variable needs to be defined for each environment
ENV RUNTIME_ENVIRONMENT=dev

# this variable MAY be overridden to change the path where flag files are written to
# this is currently only used by the iwfstartup.sh file
ENV FLAGS_PATH=/data/flags

# Add labels
LABEL io.web-solutions.git-branch=$GIT_BRANCH \
    io.web-solutions.git-commit=$GIT_COMMIT \
    io.web-solutions.git-is-dirty=$GIT_DIRTY \
    io.web-solutions.build-creator=$BUILD_CREATOR \
    io.web-solutions.build-number=$BUILD_NUMBER

# copy assets
COPY ./assets/ /
RUN chmod +x /usr/local/bin/wait-for.sh && \
    chmod +x /usr/local/bin/iwfstartup.sh && \
    chmod +x /usr/local/bin/iwfsfconsole.sh && \
    chmod +x /usr/local/bin/iwfcronenv.sh && \
    chmod +x /usr/local/bin/enable-xdebug-mod && \
    chmod +x /usr/local/bin/disable-xdebug-mod

# install locales first
RUN apt-get clean \
    && apt-get update \
    && apt-get install --no-install-recommends -y locales

# default locale: see https://wiki.debian.org/Locale // do not use LC_ALL because it overrides anything
ENV LANG=de_CH.UTF-8
ENV LANGUAGE=de_CH.UTF-8

# create locale files
RUN echo "de_CH.UTF-8 UTF-8" > /etc/locale.gen && \
    echo "de_CH ISO-8859-1" >> /etc/locale.gen && \
    echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "de_DE ISO-8859-1" >> /etc/locale.gen && \
    locale-gen

# Update System, install base stuff
RUN  apt-get install --no-install-recommends -y \
     binutils \
     less \
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
     netcat \
     wget \
     gnupg \
     cron \
     procps

# manually setup man directories because the new PHP base image seems to use a slim debian package not including manpages
# some package install scripts pretend they should be there
RUN for i in $(seq 1 8); do mkdir -p "/usr/share/man/man${i}"; done

# Install base PHP stuff
RUN apt-get --no-install-recommends install -y \
    libzip-dev \
    zlib1g-dev \
    libicu-dev \
    g++ \
    libcurl4-gnutls-dev \
    libsqlite3-dev \
    libfreetype6-dev \
    libxml2-dev \
    libmagickwand-dev \
    libjpeg-dev \
    libjpeg62-turbo-dev \
    libpng-dev && \
    \
    docker-php-ext-install curl && \
    docker-php-ext-install pdo pdo_mysql pdo_sqlite && \
    docker-php-ext-install soap && \
    # the "with" stuff has changed for PHP 7.4, see https://github.com/docker-library/php/pull/910#issuecomment-559383597
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
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

# Set time zone
RUN rm /etc/localtime && \
    ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && \
    echo date.timezone = \"${TIMEZONE}\" >>/usr/local/etc/php/conf.d/php.ini

# set TERM to xterm for bash on 2nd top line
RUN sed -i '2i\'"export TERM=xterm" /etc/bash.bashrc

# add www-data to the sudoers to allow changing to root anytime
RUN echo "www-data ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Clean up
RUN apt-get clean \
    && \
    rm -rf /tmp/* /var/tmp/* /usr/share/doc/*

# Remove lists to prevent installations
# RUN rm -rf /var/lib/apt/lists/*

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

# www-data is default user
USER www-data

# Exposed port(s)
EXPOSE 9000

# Start supervisor (see http://supervisord.org) with sudo (as root)
ENTRYPOINT ["/usr/local/bin/iwfstartup.sh"]
CMD ["/usr/bin/sudo", "-E", "/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/iwfsupervisor.conf"]
