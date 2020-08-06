#/bin/bash

#> nohup bash pledge-auto.sh 2>&1 &

count=100   #
interval=1200   #sec

#info
echo -e "\033[34m nohup bash pledge-auto.sh 2>&1 & \033[0m"

for i in $(seq ${count}); 
do 
  echo "  `date`  pledge all ${count} run $i " >> ./auto-pledge.log
  lotus-miner sectors pledge
  sleep ${interval}
done

