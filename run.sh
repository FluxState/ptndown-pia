#!/bin/bash

killall stoppropaganda.exe
killall db1000n

killall openvpn
sleep 1

set -e

echo 'nameserver 1.1.1.1' > /etc/resolv.conf

cd /opt/pia/
PIA_DNS='false' PIA_PF='false' VPN_PROTOCOL='openvpn_udp_standard' DISABLE_IPV6='yes' \
  PREFERRED_REGION="$(shuf -n 1 /config/regions)" \
  ./run_setup.sh

shuf /config/resolv.conf > /etc/resolv.conf

/opt/go/bin/db1000n --prometheus_on="$DBN_PROMETHEUS" &
/opt/stoppropaganda.exe --useragent="$SP_USERAGENT" &
