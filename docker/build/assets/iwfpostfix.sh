#!/bin/bash
rm -f /var/lib/postfix/master.lock
postfix set-permissions

postfix start
tail -f /var/log/mail.log
