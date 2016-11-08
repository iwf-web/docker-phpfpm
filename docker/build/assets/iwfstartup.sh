#!/bin/bash
#set -x

DATA_PATH=/data/dockerinit.d/php-fpm

echo -e "\n------------------------------------------------------------"
echo "$(date): Starting up ..."

echo "$(date): Executing startup scripts ..."

for file in `find "$DATA_PATH" -name "*.sh" -type f | sort -n`
do
  echo "$(date): Executing script ${file} ..."
  sh ${file}
done

echo "$(date): Starting $@ ..."
exec "$@"
