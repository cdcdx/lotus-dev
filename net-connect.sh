#!/bin/bash

#> vi lotus/build/bootstrap/bootstrappers.pi

if [ -z $1 ]; then 
  bootstrap="
/dns4/bootstrap-0.calibration.fildev.network/tcp/1347/p2p/12D3KooWPmhFGJkE7wDUdtzDYr7ReML9vgzJ8Tv7ubh9T6Le1Bmn
/dns4/bootstrap-1.calibration.fildev.network/tcp/1347/p2p/12D3KooWGwv2YtXyYPrEKssttUT3TKZknPkCWKR6WVTvt9LW4hdf
/dns4/bootstrap-2.calibration.fildev.network/tcp/1347/p2p/12D3KooWPWUw5yEet6NWpxhxoibXFbLprG4k5PMLKLeubGBLf6nd
/dns4/bootstrap-3.calibration.fildev.network/tcp/1347/p2p/12D3KooWHgMU953YxD5skVG3RKa58TXwVL9z5ycGKrZdaFzGpouT
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
