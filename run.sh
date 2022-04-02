#!/bin/bash

killall stoppropaganda.exe
killall db1000n

killall openvpn
sleep 1

set -e

echo 'nameserver 1.1.1.1' >/etc/resolv.conf

cd /opt/pia/
PIA_DNS='false' PIA_PF='false' VPN_PROTOCOL='openvpn_udp_standard' DISABLE_IPV6='yes' \
PREFERRED_REGION="$(shuf -n 1 /config/regions | sed -e 's/\r//' | sed -e 's/\n//')" \
/opt/pia/run_setup.sh

shuf /config/resolv.conf >/etc/resolv.conf

/go/bin/db1000n --prometheus_on="$DBN_PROMETHEUS" &
/go/bin/stoppropaganda.exe --dnstimeout 500ms --timeout 5s --useragent="$SP_USERAGENT" &
