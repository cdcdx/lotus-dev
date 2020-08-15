#! /bin/bash
## frp [https://github.com/fatedier/frp]

remoteip=`curl ip.sb`
localip=`ip addr show |awk -F '[ /]+' '$0~/inet/ && $0~/brd/ {print $3}'`

#frp_url_lnx=http://111.230.145.160/frp_0.33.0_linux_amd64.tar.gz
frp_url_lnx=http://182.150.0.20/frp_0.33.0_linux_amd64.tar.gz

server_ip=182.150.0.20
server_port=7000
dashboard_port=7500
#server_ip=120.79.34.177
#server_port=6000
#dashboard_port=6500

check_ufw(){
  RESULT=$(sudo ufw status)
  RESULT=${RESULT:8:10}
  #echo $RESULT
  if [ $RESULT == "inactive" ]; then
    status_ufw=0
    return 0
  else
    status_ufw=1
    return 1
  fi
}

check_iptables(){
  RESULT=$(sudo service iptables status)
  RESULT=${RESULT:22:9}
  #echo $RESULT
  if [ -z $RESULT ]; then
    status_iptables=0
    return 0
  else
    status_iptables=1
    return 1
  fi
}

check_mask(){
  while [[ -z $mask ]]
  do
  echo -e "\033[34m 
  Select mask:          [`hostname`]  $localip  $remoteip
    
    1 - ip_mask
    2 - host_mask  (default)
    3 - custom_mask
    
    99 - exit
    \033[0m "
    read -e -p "Input:" mask_type
    if [ -z $mask_type ]; then
      mask_type=2
    fi
    echo " "
    if [ $mask_type -eq 1 ]; then  #ip
      #localip_tmp=${localip%.*}
      #mask=${localip_tmp##*.}.${localip##*.}
      localip_tmp=${localip#*.}
      mask=${localip_tmp#*.}
    elif [ $mask_type -eq 2 ]; then  #host
      mask=`hostname`
    elif [ $mask_type -eq 3 ]; then  #custom
      read -e -p "mask:" mask
    elif [ $mask_type -eq 99 ]; then
      exit 1
    else
      echo -e "\033[31m Input error \033[0m"
    fi
  done
  echo " "
}

while [[ -z $frp_order ]]
do
  echo -e "\033[34m 
  Select frp:          [`hostname`]  $localip  $remoteip
    
    0 - remove frp*
    1 - server amd64
    2 - client amd64  (default)
    
    99 - exit
    \033[0m "
  read -e -p "Input:" frp_order
  if [ -z $frp_order ]; then
    frp_order=2
  fi
  
  echo " "
  if [ $frp_order -eq 0 ]; then  #remove frp*
  {
      systemctl stop frp*.service
      systemctl disable frp*.service
      netstat -ntlp |grep frp
      rm -rf /lib/systemd/system/frp*.service
      rm -rf /opt/frp*
      rm -rf /etc/frp*
      rm -rf /usr/bin/frp*
  }
  elif [ $frp_order -eq 1 ]; then  #server amd64
  {
    if [ ! -z "/opt/frp/frps.ini" ]; then
      rm -rf /opt/frp*
      wget -c $frp_url_lnx -O frp_linux_amd64.tar.gz
      tar xvf frp_linux_amd64.tar.gz -C /opt/
      mv /opt/frp_* /opt/frp
      rm -rf /opt/frp/frpc* /opt/frp/systemd/frpc*
    else
      systemctl stop frps.service
    fi

    echo "[common]
bind_addr = 0.0.0.0
bind_port = $server_port
bind_udp_port = 6001
#kcp_bind_port = $server_port

log_file = /opt/frp/log_run_frps.log
log_level = warn
log_max_days = 3
disable_log_color = false
detailed_errors_to_client = true

authentication_method = token
token = C57bX6rtxYMrS7hw

allow_ports = 6000-6009,1347,5427-5430
max_pool_count = 500
max_ports_per_client = 0

#dashboard
dashboard_addr = 0.0.0.0
dashboard_port = $dashboard_port
dashboard_user = admin
dashboard_pwd = admin888" > /opt/frp/frps.ini && chmod 600 /opt/frp/frps.ini
    
    # 防火墙
    check_ufw
    if [ $status_ufw -eq 1 ]; then
      sudo ufw allow $server_port
      sudo ufw allow $dashboard_port
    fi
    check_iptables
    if [ $status_iptables -eq 1 ]; then
      iptables -I INPUT -p tcp --dport $server_port -j ACCEPT
      iptables -I INPUT -p tcp --dport $dashboard_port -j ACCEPT
      service iptables save && iptables -L -n
      systemctl restart iptables.service && systemctl enable iptables.service
    fi
    echo " "
    
    # 开机启动 server 1
    if [ ! -d "/etc/frp" ]; then 
      mkdir /etc/frp/ && chmod 700 /etc/frp/
    fi
    sed -i 's/User=nobody/User=root/g'  /opt/frp/systemd/frps.service
    if [ -f "/usr/bin/frps" ]; then
      rm /usr/bin/frps
    fi
    if [ -f "/etc/frp/frps.ini" ]; then
      rm /etc/frp/frps.ini
    fi
    ln -s /opt/frp/frps /usr/bin/frps
    ln -s /opt/frp/frps.ini /etc/frp/frps.ini
    cp /opt/frp/systemd/frps.service /lib/systemd/system/ && chmod +x /lib/systemd/system/frps.service
    systemctl enable frps.service && systemctl start frps.service
    service frps start && netstat -ntlp |grep frp
    
    echo $remoteip
  }
  elif [ $frp_order -eq 2 ]; then  #client amd64
  {
    if [ ! -z "/opt/frp/frpc.ini" ]; then
      rm -rf /opt/frp*
      wget -c $frp_url_lnx -O frp_linux_amd64.tar.gz
      tar xvf frp_linux_amd64.tar.gz -C /opt/
      mv /opt/frp_* /opt/frp
      rm -rf /opt/frp/frps* /opt/frp/systemd/frps*
    else
      systemctl stop frpc.service
    fi
    # 输入  mask
    check_mask
    
    # 输入  ssh_port tcp_port
    read -e -p " client mask is ssh_$mask, please input ssh_port:" ssh_port
    read -e -p " client mask is tcp_$mask, please input tcp_port:" tcp_port
    
    echo "[common]
server_addr = $server_ip
server_port = $server_port

log_file = /opt/frp/log_run_frpc.log
log_level = warn
log_max_days = 3

token = C57bX6rtxYMrS7hw
pool_count = 100
" > /opt/frp/frpc.ini
    
    if [ ! -z $ssh_port ]; then
      echo "
[ssh_$mask]
type = tcp
local_ip = 127.0.0.1
local_port = 22
remote_port = $ssh_port
use_encryption = true
#use_compression = true
" >> /opt/frp/frpc.ini
    fi 
    
    if [ ! -z $tcp_port ]; then
      echo "
[tcp_$mask]
type = tcp
local_ip = 127.0.0.1
local_port = $tcp_port
remote_port = $tcp_port
use_encryption = true
#use_compression = true
" >> /opt/frp/frpc.ini
    fi
    
    chmod 600 /opt/frp/frpc.ini
    
    # 防火墙
    check_ufw
    if [ $status_ufw -eq 1 ]; then
      sudo ufw allow server_port
      sudo ufw allow $dashboard_port
      if [ ! -z $ssh_port ]; then
        sudo ufw allow $ssh_port
      fi
      if [ ! -z $tcp_port ]; then
        sudo ufw allow $tcp_port
      fi
    fi
    check_iptables
    if [ $status_iptables -eq 1 ]; then
      iptables -I INPUT -p tcp --dport server_port -j ACCEPT
      iptables -I INPUT -p tcp --dport $dashboard_port -j ACCEPT
      if [ ! -z $ssh_port ]; then
        iptables -I INPUT -p tcp --dport $ssh_port -j ACCEPT
      fi
      if [ ! -z $tcp_port ]; then
        iptables -I INPUT -p tcp --dport $tcp_port -j ACCEPT
      fi
      service iptables save && iptables -L -n
      systemctl restart iptables.service && systemctl enable iptables.service
    fi
    echo " "
    
    # 开机启动 client 1
    if [ ! -d "/etc/frp" ]; then 
      mkdir /etc/frp/ && chmod 700 /etc/frp/
    fi
    sed -i 's/User=nobody/User=root/g'  /opt/frp/systemd/frpc.service
    if [ -f "/usr/bin/frpc" ]; then
      rm /usr/bin/frpc
    fi
    if [ -f "/etc/frp/frpc.ini" ]; then
      rm /etc/frp/frpc.ini
    fi
    ln -s /opt/frp/frpc /usr/bin/frpc
    ln -s /opt/frp/frpc.ini /etc/frp/frpc.ini
    cp /opt/frp/systemd/frpc.service /lib/systemd/system/ && chmod +x /lib/systemd/system/frpc.service
    systemctl enable frpc.service && systemctl start frpc.service
    service frpc start && netstat -ntlp |grep frp
    
  }
  elif [ $frp_order -eq 99 ]; then
    exit 1
  else
    echo -e "\033[31m Input error \033[0m"
  fi
done
