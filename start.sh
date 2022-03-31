#!/usr/bin/dumb-init /bin/sh

touch /var/log/ptndown.log

service cron start

bash /run.sh >>/var/log/ptndown.log

tail -f /var/log/ptndown.log
