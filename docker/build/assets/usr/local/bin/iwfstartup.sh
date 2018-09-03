#!/bin/bash
#set -x

DATA_PATH=/data/dockerinit.d
RUN_ONCE_PATH=${DATA_PATH}/initial
RUN_ONCE_FLAG=${FLAGS_PATH}/initial-run-done

echo -e "\n------------------------------------------------------------"
echo "$(date): Starting up ..."

if [ ! -d "${FLAGS_PATH}" ]; then
    echo "$(date): (INITIAL) The folder '${FLAGS_PATH}' does not exist. Please mount it as a volume to support running initial scripts in ${RUN_ONCE_PATH}."
    echo "$(date): (INITIAL) To change the folder please override the environment variable FLAGS_PATH."
fi

if [ -d "$RUN_ONCE_PATH" ] && [ -d "${FLAGS_PATH}" ]; then
    if [ -f "$RUN_ONCE_FLAG" ]; then
      echo "$(date): (INITIAL) Flag file found -- not executing files in "initial" folder."
      echo "$(date): (INITIAL) Please delete the file '${RUN_ONCE_FLAG}' if you want to run the scripts in ${RUN_ONCE_PATH} again.";
    else
      echo "$(date): (INITIAL) Executing scripts in 'initial' folder with /bin/sh ..."

      for file in `find "$RUN_ONCE_PATH" -maxdepth 1 -name "*.sh" -type f | sort -n`
      do
        echo "$(date): Executing INITIAL script ${file} ..."
        sh ${file}
      done

      touch "$RUN_ONCE_FLAG"
      echo "$(date): (First start) Wrote flag file to prevent running the initial scripts again.";

    fi
elif [ ! -d "$RUN_ONCE_PATH" ]; then
  echo "$(date): (INITIAL) Folder '${RUN_ONCE_PATH}' not found -- please consider adding it and move the scripts that should only be run on the first deployment.";
fi

echo "$(date): Executing startup scripts with /bin/sh ..."

for file in `find "$DATA_PATH" -maxdepth 1 -name "*.sh" -type f | sort -n`
do
  echo "$(date): Executing script ${file} ..."
  sh ${file}
done

echo "$(date): Starting $@ ..."
exec $@
