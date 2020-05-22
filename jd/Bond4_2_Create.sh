#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    Bond4_2_Create.sh
# Revision:    1.0
# Date:        2020/04/07
# Author:      Yibo Chan
# Email:       chenyibo2@jd.com
# Description: The second step of creating bond4
# Notes:       在确认第二个网卡正常启动后，使用该脚本创建bond4配置
#               https://cf.jd.com/pages/viewpage.action?pageId=271624483
# Copyright:   2020
# License:     GPL
# -------------------------------------------------------------------------------

set -x

check_network(){
    device1=$(ls -l /sys/class/net |grep `lspci |grep -E "10-Gigabit|10GbE|SFP+|Lx" |awk '(NR==2){print $1}'` |awk -F"/" '{print $NF}')
    if [ ${device1}X == "eth1X" ];then
        echo "eth1 works"
    else
        echo "eth1 donot work,please check it!!!"
        exit 1
    fi
}

load_bongding_driver(){
    mode=$(cat /boot/config-3.10.0-693.el7.x86_64 | grep -i bonding | awk -F '=' '{print $2}')
    if [ ${mode}X == "mX" ];then
        echo "bonding dirver can be loaded"
    else
        echo "mode is ${mode}, please check it with commond:"
        echo "cat /boot/config-3.10.0-693.el7.x86_64 | grep -i bonding"
        exit 1
    fi

cat <<EOF > /etc/modprobe.d/bond.conf
alias bond0 bonding
options bond0 miimon=100 mode=4 lacp_rate=1 xmit_hash_policy=layer3+4
EOF
}

bak_net_conf(){
    cd /etc/sysconfig/network-scripts/
    if [ -f ifcfg-bond0 ];then
        echo "bond0 has been existed"
        \cp ifcfg-bond0 bak_ifcfg-bond0
        \cp ifcfg-eth0 bak_ifcfg-eth0_bond4
        \cp ifcfg-eth1 bak_ifcfg-eth1_bond4
    elif [ -f ifcfg-eth1 ] && [ ! -f bak_ifcfg-eth1 ];then
        cp ifcfg-eth1 bak_ifcfg-eth1
    else
        echo "there is no bond0"
    fi
}

generate_bond0(){
    cd /etc/sysconfig/network-scripts/
    if [ -e ifcfg-bond0 ];then
        eth0_conf="bak_ifcfg-eth0"
    else
        eth0_conf="ifcfg-eth0"
    fi

cat <<EOF > ifcfg-bond0
DEVICE=bond0
ONBOOT=yes
BOOTPROTO=static
TYPE=Bond
USERCTL=no
IPV6INIT=no
EOF

    grep IPADDR /etc/sysconfig/network-scripts/${eth0_conf} >> ifcfg-bond0
    grep NETMASK /etc/sysconfig/network-scripts/${eth0_conf} >> ifcfg-bond0
    grep GATEWAY /etc/sysconfig/network-scripts/${eth0_conf} >> ifcfg-bond0
}

generate_eth0_and_eth1(){
    cd /etc/sysconfig/network-scripts/

cat <<EOF > ifcfg-eth0
DEVICE=eth0
ONBOOT=yes
BOOTPROTO=none
MASTER=bond0
SLAVE=yes
USERCTL=no
EOF

cat <<EOF > ifcfg-eth1
DEVICE=eth1
ONBOOT=yes
BOOTPROTO=none
MASTER=bond0
SLAVE=yes
USERCTL=no
EOF

    device0="eth0"
    device1=$(ls -l /sys/class/net |grep `lspci |grep -E "10-Gigabit|10GbE|SFP+|Lx" |awk '(NR==2){print $1}'` |awk -F"/" '{print $NF}')
    net_mac0=$(cat /sys/class/net/${device0}/address)
    net_mac1=$(cat /sys/class/net/${device1}/address)
    echo "HWADDR=${net_mac0}" >> ifcfg-eth0
    echo "HWADDR=${net_mac1}" >> ifcfg-eth1
}

restart_network(){
    systemctl status network.service
    read -r -p "Would you like to restart network service? [Y|y/N|n] " input
    case $input in
        [yY][eE][sS]|[yY])
            echo "Your's answer is: Yes"
            systemctl restart network.service
            ;;
        [nN][oO]|[nN])
            echo "Your's answer is: No"
            exit 1
            ;;
        *)
            echo "Invalid input..."
            exit 1
            ;;
    esac
    systemctl status network.service
}

restart_network_quiet(){
    systemctl restart network.service
}

####main
check_network
load_bongding_driver
bak_net_conf
generate_bond0
generate_eth0_and_eth1
#restart_network
restart_network_quiet
