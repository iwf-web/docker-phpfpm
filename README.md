# IWF PHP-FPM Docker Base Image


## Overview

This is a PHP-FPM image based on the official `php:7.3-fpm` image. 

It's a vital part of the IWF application stack.

This image contains a lot of tools, configs, PHP modules and scripts for easy development.

It can be used together with our [Nginx base image](https://hub.docker.com/repository/docker/iwfwebsolutions/nginx). 

See our [Symfony Vagrant Docker Example Project](https://github.com/iwf-web/symfony-vagrant-docker-example) for a usage example.

The following releases are available:

- [releases/PHP-PFM-7.1](https://github.com/iwf-web/docker-phpfpm/tree/releases/PHP-FPM-7.1)
- [releases/PHP-PFM-7.3](https://github.com/iwf-web/docker-phpfpm/tree/releases/PHP-FPM-7.3)
- [releases/PHP-PFM-7.4](https://github.com/iwf-web/docker-phpfpm/tree/releases/PHP-FPM-7.4)


See the branches for release specific information.


## Links

The image is built weekly based on the official image `php:7.X-fpm-stretch` (7.1/7.3) or `php:7.X-fpm-buster` (7.4).

It's available here: https://hub.docker.com/repository/docker/iwfwebsolutions/phpfpm

You should always use the tag: `iwfwebsolutions/phpfpm:7.X-latest`, replacing `X` with the PHP minor version.


## Versions

The X part of the version number `7.MINOR-X` is always increased when we update the image configuration (e.g. config files).

It is NOT an indication to the patch level of the base image. It's **always** the **latest** PHP image of the supplied minor version (currently 7.1 and 7.3).

See the CHANGELOG to find out the details.


## What's inside?

This image includes the following stuff:

- frequently used shell commands
- the most important PHP modules
- a custom PHP configuration (php.ini)
- a customized OS configuration (e.g. locales)
- Process handler (supervisor) for starting php-fpm and cron
- various scripts for the individualization of projects


## Changes & additions to the official base image

Change                      | Description
----------------------------|--------------
Installed software (OS level)  | curl, git, unzip, vim, wget, ruby, openssh-client, sudo, dnsutils, openssl, nano, supervisor, netcat, wget, gnupg, cron, composer, locales, procps, less
Installed PHP modules       | curl, pdo, pdo_mysql, pdo_sqlite, soap, gd, intl, iconv, exif, zip, imagick, opcache
php.ini                     | see below and the [php.ini file](https://github.com/iwf-web/docker-phpfpm/blob/releases/PHP-FPM-7.3/docker/build/assets/usr/local/etc/php/conf.d/php.ini)
Supervisor daemon config    | `/etc/supervisor/conf.d/iwfsupervisor.conf`: Supervises the services **php-fpm** and **cron**.<br>Logs go to: `/var/log/supervisor/`
Installed scripts           | see below (helper scripts)
OS settings                 | see below (OS settings)
Entrypoint                  | `/usr/local/bin/iwfstartup.sh` (see startup scripts below)
Command                     | `/usr/bin/supervisord -c /etc/supervisor/conf.d/iwfsupervisor.conf`

### access rights

- default user: www-data
- scripts will be started as: www-data
- supervisor starts as `root`, php-fpm runs as `root`, php-fpm childs run as `www-data`, cron runs as `root`

### updated php.ini settings

- max_execution_time = 300
- date.timezone = 'Europe/Zurich'
- max_input_time = 60
- memory_limit = 2048M
- upload_max_filesize = 500M
- max_file_uploads = 20
- opcache.enable=1
- opcache.max_accelerated_files=20000


### updated OS settings

- set timezone to Europe/Zurich (todo: add ENV for that)
- installed locales:
    * de_CH.UTF-8 UTF-8
    * de_CH ISO-8859-1
    * de_DE.UTF-8 UTF-8
    * de_DE ISO-8859-1
- default locale: de_CH.UTF-8
- allow sudo for www-data user (in `/etc/sudoers`)
- create directory `/app` for mounting application files

 
## Usage / Environment variables


Environment variable  | default value  | Description
----------------------|----------------|---------------
RUNTIME_ENVIRONMENT   | dev            | should be used by custom scripts to use the correct settings. Suggested values: `local`, `dev`, `qa`, `prod`
FLAGS_PATH            | /data/flags    | Used by scripts to store flag files that must survive a re-deployment.<br>Currently only used by `iwfstartup.sh` to mark the execution of "run once" initial scripts.
CLEAR_SESSIONS_IN     | (empty)        | If you store PHP sessions in files you should specify the directory here where your session files are located. A cronjob will then execute the PHP garbage collection for session files every night.


## Included helper scripts

All the scripts live in `/usr/local/bin`.

### wait-for.sh

Waits for a specific amount of time until a specific network service answers. Used to wait on startup until dependent containers are started.

Usage: `wait_for.sh -t TIMEOUT HOST:PORT`

Example: `wait_for.sh -t 600 db:3306` (waits for max. 600 seconds until "db" container answers on port 3306)


### iwfstartup.sh

Is executed as Entrypoint at the start of the container as user www-data. Has sudo rights, i.e. permission changes etc. are executed with sudo as root.

Executes all scripts in `/data/dockerinit.d`, ordered by file name.

Executes all scripts in `/data/dockerinit.d/initial` **ONCE**, ordered by file name. This should contain all scripts that should only be executed during initial deployment, e.g. "fix-permissions.sh". After all scripts have been run, the flag file "initial-run-done" is written to the folder `FLAGS_PATH` (environment variable, default: /data/flags), which prevents future execution.


### iwfcronenv.sh

Used for Cronjobs. Executes commands with correct environment. Use absolute paths.

For this to work, the script `XX_export_variables.sh` should exist in `/data/dockerinit.d`, which adds variables to the Env file `/usr/local/bin/iwfsfconsole.env`.

See the usage example in our [Example Project](https://github.com/iwf-web/symfony-vagrant-docker-example)




## Extension points (change or extend configuration)

Use this image as a base image for your own application image.

A good to control what's called on application startup is the directory: `/data/dockerinit.d`

Copy your startup scripts into that directory, and they'r executed by `iwfstartup.sh`.

See a good set of the scripts in the usage example in our [Example Project](https://github.com/iwf-web/symfony-vagrant-docker-example)


## Contribute!

Contribute to this project and all the other's by creating issues & pull requests.

Thanks for your help!


## Get help

Use the [issue system on Github](https://github.com/iwf-web/docker-phpfpm) to report errors or suggestions.

You can also write to opensource@iwf.io. We try to answer every question, but it might take some days.

 
