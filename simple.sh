#!/bin/bash

ENV_SECTOR_SIZE=32GiB

while [[ -z $method ]] || (( "4 < $method < 10" ))
do
  echo -e "\033[34m 
  Select:      [`hostname`]  
    0 - lotus-miner storage-deals list
    1 - lotus client list-deals -v
    2 - lotus state get-deal [DealID]
    3 - lotus mpool pending --local |wc -l && lotus mpool pending |wc -l
    
    4 - lotus-miner sectors pledge
    5 - lotus-miner info --color true
    6 - lotus-miner storage list --color true
        lotus-miner storage list --color true |grep GiB
    7 - lotus-miner sealing workers --color true
        lotus-miner sealing workers --color true |grep Worker
        lotus-miner sealing workers --color true |grep CPU
    8 - lotus-miner sectors list
    9 - lotus-miner sealing jobs --color true
    11 - lotus-miner sectors status --log $sector
    12 - lotus-miner sectors update-state --really-do-it $sector [status]
    13 - lotus-miner sectors remove --really-do-it $sector
    
    14 - lotus-miner proving info
    15 - lotus-miner proving deadlines
    16 - lotus-miner actor withdraw
    17 - lotus-miner storage-deals set-ask --price 52000 --verified-price 51000 --min-piece-size 256B --max-piece-size $ENV_SECTOR_SIZE
    18 - lotus-miner storage-deals get-ask
       - lotus-miner actor set-addrs /ip4/8.129.171.72/tcp/5427
       - lotus-miner actor set-addrs /ip4/182.150.0.20/tcp/5427

    19 - lotus send --from=$owner --method=14 --params-json='\"967837395419938875527\"' [MinerID] [MinerBalance]
    20 - lotus wallet new bls
    21 - lotus wallet list |grep t3
    22 - lotus sync wait
    23 - lotus sync status
    24 - lotus fetch-params $ENV_SECTOR_SIZE

    25 - lotus net listen
    26 - lotus net peers && lotus net peers|wc -l
    27 - lotus-miner net listen
    28 - lotus-miner net peers && lotus-miner net peers|wc -l
    
    \033[0m"
  
  while [[ -z $method ]]
  do
    read -e -p "Input:" method
    if  [ ! -n "$method" ] && [ -n "$method_old" ]; then
      method=$method_old
    fi
    if echo $method |grep -q '[^0-9]'; then
      $method
      unset method
    fi
  done
  echo " "
  if [ $method -eq 0 ]; then  # lotus-miner storage-deals list
    lotus-miner storage-deals list
  elif [ $method -eq 1 ]; then  # lotus client list-deals -v
    lotus client list-deals -v
  elif [ $method -eq 2 ]; then  # lotus state get-deal [DealID]
  {
    while [ -z $deal ]
    do
      read -e -p '  please input Deal ID:' deal
      if [ -z $deal ]; then
        unset deal
      fi
    done
    #echo ' '

    lotus state get-deal $deal
  }
  elif [ $method -eq 3 ]; then  # lotus mpool pending --local |wc -l && lotus mpool pending |wc -l
    lotus mpool pending --local |wc -l && lotus mpool pending |wc -l
  elif [ $method -eq 4 ]; then  # lotus-miner sectors pledge
  {
    #num
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
    
    
    # tips
    echo -e "\033[34m lotus-miner sectors pledge $worker * $num \033[0m"
    
    check_areyousure
    if [ $areyousure -eq 1 ]; then
      #lotus-miner sectors pledge $worker
      for i in $(seq $num); 
      do 
        echo "    pledge $worker all $num run $i"
        lotus-miner sectors pledge $worker
      done
    fi
  }
  elif [ $method -eq 5 ]; then  # lotus-miner info
    lotus-miner info
  elif [ $method -eq 6 ]; then  # lotus-miner storage list --color true
    lotus-miner storage list --color true
  elif [ $method -eq 7 ]; then  # lotus-miner sealing workers --color true
    lotus-miner sealing workers --color true
  elif [ $method -eq 8 ]; then  # lotus-miner sectors list
    lotus-miner sectors list
  elif [ $method -eq 9 ]; then  # lotus-miner sealing jobs --color true
    lotus-miner sealing jobs --color true
  elif [ $method -eq 11 ]; then  # lotus-miner sectors status --log
  {
    while [ -z $sector ]
    do
      read -e -p "  please input sector:" sector
      if [ -z $sector ]; then
        unset sector
      elif echo $sector |grep -q '[^0-9]'; then
        unset sector
      elif [ $sector -le 0 ] && [ $sector -ge 65535 ]; then
        unset sector
      fi
    done
    echo " "
    
    # tips
    echo -e "\033[34m lotus-miner sectors status --log $sector \033[0m"
    
    lotus-miner sectors status --log $sector
  }
  elif [ $method -eq 14 ]; then  # lotus-miner proving info
    lotus-miner proving info
  elif [ $method -eq 15 ]; then  # lotus-miner proving deadlines
    lotus-miner proving deadlines
  elif [ $method -eq 16 ]; then  # lotus-miner actor withdraw
    lotus-miner actor withdraw
  elif [ $method -eq 17 ]; then  # lotus-miner storage-deals set-ask --price 52000 --verified-price 51000 --min-piece-size 256B --max-piece-size $ENV_SECTOR_SIZE
    lotus-miner storage-deals set-ask --price 52000000 --verified-price 51000000 --min-piece-size 256B --max-piece-size $ENV_SECTOR_SIZE
  elif [ $method -eq 18 ]; then  # lotus-miner storage-deals get-ask
    lotus-miner storage-deals get-ask
  elif [ $method -eq 19 ]; then  # lotus send --from=$owner --method=14 --params-json='\"967837395419938875527\"' [MinerID] [MinerBalance]
  {
    while [ -z $minerid ]
    do
      read -e -p "  please input minerid:" minerid
      if [ -z $minerid ]; then
        unset minerid
      elif ! echo $minerid | grep -q '^t0[0-9]\{4,8\}$' ; then
        unset minerid
      fi
    done
    echo " "
    while [ -z $balance ]
    do
      read -e -p "  please input send_balance:" balance
      if [ -z $balance ]; then
        unset balance
      elif echo $balance | grep -q '[^0-9]'; then
        unset balance
      elif [ $balance -le 0 ] && [ $balance -ge 65535 ]; then
        unset balance
      fi
    done
    echo " "
    
    #info
    echo -e "\033[34m  lotus send --from=$owner --method=14 --params-json='\"967837395419938875527\"' $minerid $balance \033[0m"
    
    lotus send --from=$owner --method=14 --params-json='"967837395419938875527"' $minerid $balance
  }
  elif [ $method -eq 20 ]; then  # lotus wallet new bls
    lotus wallet new bls
  elif [ $method -eq 21 ]; then  # lotus wallet list |grep t3
    lotus wallet list |grep t3
  elif [ $method -eq 22 ]; then  # lotus sync wait
    lotus sync wait
  elif [ $method -eq 23 ]; then  # lotus sync status
    lotus sync status
  elif [ $method -eq 24 ]; then  # lotus fetch-params $ENV_SECTOR_SIZE
    lotus fetch-params $ENV_SECTOR_SIZE
  elif [ $method -eq 25 ]; then  # lotus net listen
    lotus net listen
  elif [ $method -eq 26 ]; then  # lotus net peers
    lotus net peers && echo " " && lotus net peers|wc -l
  elif [ $method -eq 27 ]; then  # lotus-miner net listen
    lotus-miner net listen
  elif [ $method -eq 28 ]; then  # lotus-miner net peers
    lotus-miner net peers && echo " " && lotus-miner net peers|wc -l
  elif [ $method -eq 99 ]; then  # exit
    exit 1
  else  # error
  {
    echo " "
    echo -e "\033[31m Input error \033[0m"
  }
  fi
  
  method_old=$method
  echo " "
  pause && unset method worker work num sector minerid balance monitor_type start end monitor_sector height 
  
done
