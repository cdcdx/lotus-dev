#!/bin/bash

if [ -z $1 ]; then 
  bootstrap="
/dns4/bootstrap-0.calibration.fildev.network/tcp/1347/p2p/12D3KooWBEDQ5Xwh3JC67yxjNf91pZcpavrAwaqprNzbquC1yj6t
/dns4/bootstrap-1.calibration.fildev.network/tcp/1347/p2p/12D3KooWKbUF17McnN516w8TjmbkVNkcAZS9LnE5yJwH7pVDYPUJ
/dns4/bootstrap-2.calibration.fildev.network/tcp/1347/p2p/12D3KooWLbhs34AsH22DF25vLAao4xKbnBp8ZVzz3bbrv9AiATsG
/dns4/bootstrap-3.calibration.fildev.network/tcp/1347/p2p/12D3KooWQT7zYxZetuYcRsyRiT46SXTV6k1ApGqd9XudCuKTmCmB
"
else 
  bootstrap="$1"
fi


for i in $bootstrap
do 
  if [ ! -z $i ]; then
    echo $i
    lotus-miner net connect $i
  fi
done
