#!/bin/bash

if [ -n "${CLEAR_SESSIONS_IN}" ]; then
  echo "Running garbage collection on PHP sessions in ${CLEAR_SESSIONS_IN}"
  /usr/local/bin/php -d session.save_path="${CLEAR_SESSIONS_IN}" \
    -d session.gc_probability=1 \
    -d session.gc_divisor=1 \
    -r "session_start(); session_destroy();"
fi
