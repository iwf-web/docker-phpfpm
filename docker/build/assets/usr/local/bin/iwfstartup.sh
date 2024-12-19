#!/bin/bash
#set -x

DATA_PATH=/data/dockerinit.d
RUN_ONCE_PATH=${DATA_PATH}/initial
RUN_ONCE_FLAG=${FLAGS_PATH}/initial-run-done

CURRENT_TIME=$(date +"%Y-%m-%d %H:%M:%S")

echo -e "[iwfstartup] ${CURRENT_TIME} \n------------------------------------------------------------"
echo "[iwfstartup] ${CURRENT_TIME} Starting up ..."

echo "[iwfstartup] ${CURRENT_TIME} Dumping environment variables to /etc/environment."
sudo -E /usr/local/bin/update-env-file.sh

if [ ! -d "${FLAGS_PATH}" ]; then
    echo "[iwfstartup] ${CURRENT_TIME} (INITIAL) The folder '${FLAGS_PATH}' does not exist. Please mount it as a volume to support running initial scripts in ${RUN_ONCE_PATH}."
    echo "[iwfstartup] ${CURRENT_TIME} (INITIAL) To change the folder please override the environment variable FLAGS_PATH."
fi

if [ -d "$RUN_ONCE_PATH" ] && [ -d "${FLAGS_PATH}" ]; then
    if [ -f "$RUN_ONCE_FLAG" ]; then
      echo "[iwfstartup] ${CURRENT_TIME} (INITIAL) Flag file found -- not executing files in "initial" folder."
      echo "[iwfstartup] ${CURRENT_TIME} (INITIAL) Please delete the file '${RUN_ONCE_FLAG}' if you want to run the scripts in ${RUN_ONCE_PATH} again.";
    else
      echo "[iwfstartup] ${CURRENT_TIME} (INITIAL) Executing scripts in 'initial' folder with /bin/sh ..."

      for file in `find "$RUN_ONCE_PATH" -maxdepth 1 -name "*.sh" -type f | sort -n`
      do
        echo "[iwfstartup] ${CURRENT_TIME} Executing INITIAL script ${file} ..."
        sh ${file} 2>&1 | sed "s/^/[iwfstartup] ${CURRENT_TIME} /"
      done

      touch "$RUN_ONCE_FLAG"
      echo "[iwfstartup] ${CURRENT_TIME} (First start) Wrote flag file to prevent running the initial scripts again.";

    fi
elif [ ! -d "$RUN_ONCE_PATH" ]; then
  echo "[iwfstartup] ${CURRENT_TIME} (INITIAL) Folder '${RUN_ONCE_PATH}' not found -- please consider adding it and move the scripts that should only be run on the first deployment.";
fi

echo "[iwfstartup] ${CURRENT_TIME} Executing startup scripts with /bin/sh ..."

for file in `find "$DATA_PATH" -maxdepth 1 -name "*.sh" -type f | sort -n`
do
  echo "[iwfstartup] ${CURRENT_TIME} Executing script ${file} ..."
  sh ${file} 2>&1 | sed "s/^/[iwfstartup] ${CURRENT_TIME} /"
done

echo "[iwfstartup] ${CURRENT_TIME} Starting $@ ..."
exec $@
