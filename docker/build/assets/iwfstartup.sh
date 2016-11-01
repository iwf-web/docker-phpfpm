#!/bin/bash
#set -x

if [[ -n ${RUNTIME_ENVIRONMENT} ]]
  then

  TARGET_FILE=/app/app/config/parameters.yml
  BASE_LINK_FILE=/data/conf/symfony_configs/parameters_${RUNTIME_ENVIRONMENT}.yml
  DATA_PATH=/data/dockerinit.d/php-fpm

  echo "Preparing for environment ${RUNTIME_ENVIRONMENT}  ..."

  # check if file exists, then sym-link it
  if [ -a ${BASE_LINK_FILE} ]
    then

    rm -f ${TARGET_FILE}
    ln -s ${BASE_LINK_FILE} ${TARGET_FILE}

    echo "${TARGET_FILE} is pointing to ${BASE_LINK_FILE} now."

    echo 'Executing startup scripts ...'

    for file in `find "$DATA_PATH" -name "*.sh" -type f`
    do
      echo "Executing script ${file} ..."
      sh ${file}
    done

    echo "Starting $@ ..."
    exec "$@"

  else

    echo "File ${BASE_LINK_FILE} does NOT exist. Aborting."
    exit 1

  fi

else

  echo "Variable RUNTIME_ENVIRONMENT must be set. Aborting."
  exit 1

fi
