#!/usr/bin/dumb-init /bin/sh

touch /var/log/ptndown.log

echo "PIA_USER=$PIA_USER" >>/etc/environment
echo "PIA_PASS=$PIA_PASS" >>/etc/environment
echo "DBN_PROMETHEUS=$DBN_PROMETHEUS" >>/etc/environment
echo "SP_USERAGENT=$SP_USERAGENT" >>/etc/environment

service cron start

bash /run.sh >>/var/log/ptndown.log

tail -f /var/log/ptndown.log
