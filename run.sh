#!/bin/bash

killall -9 stoppropaganda.exe
killall -9 db1000n

killall openvpn
sleep 5

set -e

echo 'nameserver 1.1.1.1' >/etc/resolv.conf

cd /opt/pia/
PIA_DNS='false' PIA_PF='false' VPN_PROTOCOL='openvpn_udp_standard' DISABLE_IPV6='yes' \
PREFERRED_REGION="$(shuf -n 1 /config/regions | sed -e 's/\r//' | sed -e 's/\n//')" \
/opt/pia/run_setup.sh

/go/bin/db1000n --country-check-retries=1 --prometheus_on="$DBN_PROMETHEUS" &
sleep 5 && shuf /config/resolv.conf >/etc/resolv.conf
/go/bin/stoppropaganda.exe --dnstimeout 500ms --useragent="$SP_USERAGENT" &
