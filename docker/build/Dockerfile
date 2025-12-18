# The different stages of this Dockerfile are meant to be built into separate images
# https://docs.docker.com/develop/develop-images/multistage-build/#stop-at-a-specific-build-stage
# https://docs.docker.com/compose/compose-file/#target

# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
ARG PHP_VERSION=8.5

# -----------------------------------------------------------------------------
# PHP FPM Extension Builder
# -----------------------------------------------------------------------------
FROM php:${PHP_VERSION}-fpm-trixie AS builder

ARG DEBIAN_FRONTEND=noninteractive

# Download and cache apt packages
RUN rm -f /etc/apt/apt.conf.d/docker-clean \
    && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
# Build-Dependencies (nur für Kompilierung, nicht im finalen Image)
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get install --no-install-recommends -y \
        g++ \
        curl \
        libzip-dev \
        zlib1g-dev \
        libicu-dev \
        libcurl4-gnutls-dev \
        libsqlite3-dev \
        libfreetype6-dev \
        libxml2-dev \
        libmagickwand-dev \
        libjpeg-dev \
        libjpeg62-turbo-dev \
        libwebp-dev \
        libpng-dev \
    && rm -rf /var/lib/apt/lists/*

# PHP Extensions kompilieren (inkl. Imagick via PECL)
RUN docker-php-ext-configure gd --with-freetype --with-jpeg --with-webp \
    && docker-php-ext-install -j "$(nproc)" \
        curl \
        pdo pdo_mysql pdo_sqlite \
        soap \
        gd \
        intl \
        iconv \
        exif \
        zip \
    && pecl install imagick && docker-php-ext-enable imagick

# -----------------------------------------------------------------------------
# Base PHP FPM
# -----------------------------------------------------------------------------
FROM php:${PHP_VERSION}-fpm-trixie AS runtime

LABEL org.opencontainers.image.authors="Jens Hassler <j.hassler@iwf.ch>, Xeno Suter <x.suter@iwf.ch>, Manuele Vaccari <m.vaccari@iwf.ch>, Oliver Zieschang <o.zieschang@iwf.ch>"

# Build Arguments
ARG GIT_COMMIT
ARG GIT_BRANCH=master
ARG GIT_DIRTY=undefined
ARG BUILD_CREATOR
ARG BUILD_NUMBER
ARG TIMEZONE=Europe/Zurich

# Build Labels (für Traceability)
LABEL io.web-solutions.git-branch=$GIT_BRANCH \
    io.web-solutions.git-commit=$GIT_COMMIT \
    io.web-solutions.git-is-dirty=$GIT_DIRTY \
    io.web-solutions.build-creator=$BUILD_CREATOR \
    io.web-solutions.build-number=$BUILD_NUMBER

# Environment Variables
ENV RUNTIME_ENVIRONMENT=prod \
    FLAGS_PATH=/data/flags \
    LANG=de_CH.UTF-8 \
    LANGUAGE=de_CH.UTF-8 \
    HOME=/var/www \
    \
    # Change composer cache dir to be outside ~ (currently defaults to ~/.compose/cache) (https://getcomposer.org/doc/03-cli.md#composer-home)
    COMPOSER_HOME=/var/cache/composer

ARG DEBIAN_FRONTEND=noninteractive

# Download and cache apt packages
RUN rm -f /etc/apt/apt.conf.d/docker-clean \
    && echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
# System-Pakete installieren (ein RUN Block für effektives Cleanup)
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update \
    && apt-get -y upgrade \
    && apt-get install --no-install-recommends -y \
        locales \
        curl \
        git \
        unzip \
        openssh-client \
        sudo \
        supervisor \
        cron \
        gnupg \
        openssl \
        ca-certificates \
        ssl-cert \
        netcat-openbsd \
        # vim \
        # nano \
        # less \
        # procps \
        # dnsutils \
        # screen \
        # binutils \
        # wget \
        libzip5 \
        zlib1g \
        libicu76 \
        libcurl3-gnutls \
        libsqlite3-0 \
        libfreetype6 \
        libjpeg62-turbo \
        libwebp7 \
        libpng16-16 \
        libxml2 \
        libmagickwand-7.q16-10 \
        libgomp1 \
    \
    # Create locale files \
    && { \
        echo 'de_CH.UTF-8 UTF-8'; \
        echo 'de_CH ISO-8859-1'; \
        echo 'de_DE.UTF-8 UTF-8'; \
        echo 'de_DE ISO-8859-1'; \
    } >>/etc/locale.gen \
    && locale-gen \
    \
    # Remove ISO-2022-CN-EXT Charset (CVE-2024-2961) \
    && find /usr/lib -name "gconv-modules-extra.conf" -exec sed -i '/ISO-2022-CN-EXT/s/^/#/' {} \; 2>/dev/null || true \
    && iconvconfig \
    && (iconv -l | grep -E 'CN-?EXT' && exit 1 || true) \
    \
    # Set time zone \
    && rm -f /etc/localtime \
    && ln -s /usr/share/zoneinfo/${TIMEZONE} /etc/localtime \
    && echo "date.timezone = \"${TIMEZONE}\"" >> /usr/local/etc/php/conf.d/php.ini \
    \
    # Set TERM to xterm for bash on 2nd top line \
    && sed -i '2i\export TERM=xterm' /etc/bash.bashrc \
    \
    # Add www-data to sudoers only for specific commands (minimal privileges) \
    && { \
        echo "www-data ALL=(ALL) NOPASSWD: SETENV: /usr/bin/supervisord"; \
        echo "www-data ALL=(ALL) NOPASSWD: /usr/local/bin/update-env-file.sh"; \
    } >> /etc/sudoers \
    \
    # Add cronjob for root to clean PHP session files every night (if env var CLEAR_SESSIONS_IN is set with the session files directory) \
    # user's www-data cronjobs are usually overwritten by projects
    && mkdir -p /app \
    && chown -R www-data:www-data /var/www \
    && (crontab -l 2>/dev/null; echo "0 0 * * * /bin/bash /usr/local/bin/clear-sessions.sh") | crontab - \
    \
    # Add custom PS1
    && { \
        echo 'PS1="🐳 \[\e[38;5;46m\]\u@\h\[\e[0m\]:\[\e[38;5;33m\]\w\[\e[0m\]\\$ "'; \
    } >>/etc/bash.bashrc \
    \
    # Prepare compose cache folder
    && mkdir --parents /var/cache/composer/cache \
    \
    # Clean up \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Fix composer folder permission, because it's created as root the first time it's mounted
RUN --mount=type=cache,target=/var/cache/composer/cache \
    chown --recursive www-data:www-data /var/cache/composer/cache

# PHP Extensions aus Builder kopieren
COPY --from=builder /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=builder /usr/local/etc/php/conf.d/ /usr/local/etc/php/conf.d/

# Composer installieren
COPY --from=composer:2 /usr/bin/composer /usr/local/bin/composer

# Assets kopieren (Permissions sind im Git gesetzt)
COPY ./assets/ /

USER www-data

RUN \
    # Fix issue with GIT "detected dubious ownership in repository" error in local development due to CVE-2022-24765 (https://github.com/git/git/commit/8959555cee7ec045958f9b6dd62e541affb7e7d9)
    git config --global --add safe.directory /app \
    \
    # Smoke tests
    && php --version \
    && composer --version

ENTRYPOINT ["iwfstartup.sh"]
CMD ["sudo", "-E", "supervisord", "-c", "/etc/supervisor/supervisord.conf"]
