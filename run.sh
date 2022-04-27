#!/usr/bin/env bash

killall -9 db1000n

killall openvpn
sleep "$(shuf -i 1-30 -n 1)"

set -e

cd /opt/pia/
PIA_DNS='false' PIA_PF='false' VPN_PROTOCOL='openvpn_udp_standard' DISABLE_IPV6='yes' \
PREFERRED_REGION="$(shuf -n 1 /config/regions | sed -e 's/\r//' | sed -e 's/\n//')" \
/opt/pia/run_setup.sh

echo -e "$(curl 'https://api.my-ip.io/ip' 2> /dev/null)\n"

/go/bin/db1000n --country-check-retries=1 --log-format=console --prometheus_on="$DBN_PROMETHEUS" &
