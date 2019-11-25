# IWF PHP-FPM Docker Base Image


## Overview

This is a PHP-FPM image based on the official `php:7.3-fpm` image. 

It's a vital part of the IWF application stack.

This image contains a lot of tools, configs, PHP modules and scripts for easy development.

It can be used together with our [Nginx base image](https://hub.docker.com/repository/docker/iwfwebsolutions/nginx). 

See our [Symfony Vagrant Docker Example Project](https://github.com/iwf-web/symfony-vagrant-docker-example) for a usage example.

The following releases are available:

- [releases/PHP-PFM-7.1](https://github.com/iwf-web/docker-nginx/tree/releases/PHP-FPM-7.1)
- [releases/PHP-PFM-7.3](https://github.com/iwf-web/docker-nginx/tree/releases/PHP-FPM-7.3)

See the branches for release specific information.


## Links

The image is built weekly based on the official image `php:7.X-fpm-stretch`.

It's available here: https://hub.docker.com/repository/docker/iwfwebsolutions/phpfpm

You should always use the tag: `iwfwebsolutions/phpfpm:7.X-latest`, replacing `X` with the PHP minor version.


## Versions

The X part of the version number `7.MINOR-X` is always increased when we update the image configuration (e.g. config files).

It is NOT an indication to the patch level of the base image. It's **always** the **latest** PHP image of the supplied minor version (currently 7.1 and 7.3).

See the CHANGELOG to find out the details.


## Changes to the official base image

Change     | Description
-----------|--------------


 
## Usage / Environment variables


Environment variable  | default value  | Description
----------------------|----------------|---------------


## Default startup scripts

All the scripts in the container's `/data/dockerinit.d` folder are run on each startup:

Script       |     Description
-------------|--------------------


## Extension points (change or extend configuration)

You can insert your own configuration at these points. Just mount your own config files into these directories or create a derived image from this one and change the files as needed.

Folder      | Description
------------|-------------


## Contribute!

Contribute to this project and all the other's by creating issues & pull requests.

Thanks for your help!


## Get help

Use the [issue system on Github](https://github.com/iwf-web/docker-phpfpm) to report errors or suggestions.

You can also write to opensource@iwf.io. We try to answer every question, but it might take some days.

 
