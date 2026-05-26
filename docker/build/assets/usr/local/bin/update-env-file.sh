#!/bin/bash

# OS way through pam_env - this does not support # characters in the env values
# but does work for most cases in cron jobs even without the wrapper scripts
printenv | sed -r 's/"/\\"/g' | sed -r 's/^([^=]+=)(.*)$/\1"\2"/' > /etc/environment

# this is "source"d by iwfcronenv.sh and iwfsfconsole.sh
printenv | while IFS='=' read -r k v; do
    printf 'export %s=%q\n' "$k" "$v"
done > /usr/local/bin/iwf.env
