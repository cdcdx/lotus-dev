#/bin/bash

processor=$(grep 'processor' /proc/cpuinfo |sort |uniq |wc -l)
echo -e "\033[34m processor = $processor \033[0m" 

while [ -z $num ]
do
  read -e -p '  please input pledge number:' num
  if [ -z $num ] || [ "$num" -gt "$processor" ]; then
    echo -e "\033[34m number must <= $processor \033[0m" 
    unset num
  fi
done
#echo ' '

for i in $(seq $num); 
do 
  echo "    pledge all $num  run $i"
  lotus-miner sectors pledge
done
