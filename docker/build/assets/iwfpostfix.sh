#!/bin/bash
rm -f /var/lib/postfix/master.lock
service postfix start
# tail -f /var/log/mail.log
