#!/bin/bash
# use this script to execute Symfony commands in crontab
# add required variables to dockerinit.d script 03_export_variables.sh

set -a # all environment variables are automatically exported this way

echo -e "\n-------------------------------------------------------------------------------------"
echo -e "$(date): $0 started."

if [ "$(whoami)" != 'www-data' ]; then
  echo -e "\nPlease start script as www-data (not '$(whoami)') ... Aborting."
  exit 1
fi

PHP='/usr/local/bin/php'
SYMFCONS='/app/bin/console'
ENVFILE='/usr/local/bin/iwfsfconsole.env'

if [ -f "$ENVFILE" ]; then
    echo -e "\n==> Sourcing $ENVFILE ..."
    source "$ENVFILE"
fi

test -d /app && cd /app

CONSOLECMD=$*
echo -e "==> Executing '$PHP $SYMFCONS $CONSOLECMD' (incl. timing information) ...\n"
# start new php process with env variables file
time $PHP $SYMFCONS $CONSOLECMD

echo -e "\n-------------------------------------------------------------------------------------"
echo -e "$(date): $0 finished."
set +a