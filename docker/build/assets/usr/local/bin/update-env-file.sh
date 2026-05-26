#!/bin/bash

printenv | sed -r 's/"/\\"/g' | sed -r 's/^([^=]+=)(.*)$/\1"\2"/' > /etc/environment
