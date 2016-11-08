#!/bin/bash

# correct things...
rm -f /var/lib/postfix/master.lock
postfix set-permissions

# set runtime settings
postconf -e myhostname=$HOSTNAME && \
postconf -F '*/*/chroot = n'

# start postfix and don't end process
postfix start
tail -f /var/log/mail.log
