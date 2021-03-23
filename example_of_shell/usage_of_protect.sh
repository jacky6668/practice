#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    Bond4_1_Modify_Network_Name.sh
# Revision:    1.0
# Date:        2020/0407
# Author:      Yibo Chan
# Email:       chenyibo2@jd.com
# Description: The first step of creating bond4
# Note:        在配置bond4前需要将eth1正常启动起来
#               https://cf.jd.com/pages/viewpage.action?pageId=271624483
# Copyright:   2020(c)
# License:     GPL
# -------------------------------------------------------------------------------

#set -x

key_word="zbs|cfs|wos|ha-monitor|ha-agent|docker|qemu|nbd"

check_service(){
    index=$(ps axf | grep -E ${key_word} | grep -v grep)

    if [ ${#index} -gt 0 ];then
        echo "There are at least one process of ZBS or CFS, please check it manually!!"
        exit 1
    else
        echo "check pass"
    fi
}

hw_check(){
    # check vender, HW's Mellanox net device cant be bond
    vender=$(dmidecode -t 1 | grep Manufacturer | awk -F ' ' '{print$2}')
    if [ ${vender}X = 'Huawei'X ];then
        # check eth0
        slot_eth0=$(ls -l /sys/class/net  | grep eth0 | awk -F"/" '{print $(NF-2)}' | awk -F '0000:' '{print $2}')
        if_mallaonx_0=$(lspci |grep "Ethernet controller" | grep ${slot_eth0} | grep -i "Mellanox")
        if_intel_0=$(lspci |grep "Ethernet controller" | grep ${slot_eth0} | grep -i "Intel")
        if [ ${#if_mallaonx_0} -gt 0 ];then
            echo "eth0 is Mellanox, failed!!!"
            exit 1
        elif [ ${#if_intel_0} -gt 0 ];then
            echo "eth0 is Intel, pass"
        else
            echo "eth0 is neither Intel nor Mellanox, failed!!!"
            exit 1
        fi

        # check eth1
        slot_eth1=$(ls -l /sys/class/net  | grep eth1 | awk -F"/" '{print $(NF-2)}' | awk -F '0000:' '{print $2}')
        if_mallaonx_1=$(lspci |grep "Ethernet controller" | grep ${slot_eth1} | grep -i "Mellanox")
        if_intel_1=$(lspci |grep "Ethernet controller" | grep {$slot_eth1} | grep -i "Intel")
        if [ ${#if_mallaonx_1} -gt 0 ];then
            echo "eth1 is Mellanox, failed!!!"
            exit 1
        elif [ ${#if_intel_1} -gt 0 ];then
            echo "eth1 is Intel, pass"
        else
            echo "eth1 is neither Intel nor Mellanox, failed!!!"
            exit 1
        fi
    fi
}

inspur_check(){
    # check vender, InspurM5 can be bond
    vender=$(dmidecode -t 1 | grep Manufacturer | awk -F ' ' '{print$2}')
    if [ ${vender}X = 'Inspur'X ];then
        mode=$(dmidecode -t 1 | grep 'Product Name' | awk -F ' ' '{print$3}' | grep M5)
        if [ ${#mode} -gt 0 ];then
            echo "InspurM5, pass"
        else
            echo "mode is not M5, failed!!!"
            exit 1
        fi
    fi
}

bak_net_conf(){
    cd /etc/sysconfig/network-scripts/

    if [ -f ifcfg-eth0 ] && [ ! -f bak_ifcfg-eth0 ];then
        echo "now backup eth0"
        cp ifcfg-eth0 bak_ifcfg-eth0
    elif [ -f ifcfg-eth0 ] && [ -f bak_ifcfg-eth0 ];then
        echo "eth0 has been backuped"
    else
        echo "there is no eth0 config file, check it!!!!"
        exit 1
    fi

    if [ -f ifcfg-eth1 ] && [ ! -f bak_ifcfg-eth1 ];then
        echo "now backup eth1"
        cp ifcfg-eth1 bak_ifcfg-eth1
    elif [ -f ifcfg-eth1 ] && [ -f bak_ifcfg-eth1 ];then
        echo "eth1 has been backuped"
    else
        echo "there is no eth1 config file, continue..."
        return
    fi
}

generate_eth1(){
    cd /etc/sysconfig/network-scripts/

    # if there is ifcfg-eth1, pass
    if [ -f ifcfg-eth1 ];then
        echo "eth1 exist"
        return
    fi

    # if there is no ifcfg-eth1, generate eth1 config file
    if [ ! -f bak_ifcfg-eth0 ] && [ ! -f ifcfg-bond0 ];then
        \cp ifcfg-eth0 ifcfg-eth1
    elif [ -f bak_ifcfg-eth0 ] && [ ! -f ifcfg-bond0 ];then
        \cp bak_ifcfg-eth0 ifcfg-eth1
    elif [ -f ifcfg-bond0 ];then
        echo "eth1 has been bonded"
        return
    fi

    sed -i 's/eth0/eth1/g' ifcfg-eth1
    sed -i '/IPADDR/d' ifcfg-eth1
    sed -i '/ONBOOT/aIPADDR=' ifcfg-eth1
    sed -i '/HWADDR/d' ifcfg-eth1

    net_name=$(ls -l /sys/class/net |grep `lspci |grep "Ethernet controller" |awk '(NR==2){print $1}'` |awk -F"/" '{print $NF}')
    net_mac1=$(cat /sys/class/net/${net_name}/address)
    if [ -z "${net_name}" ] && [ -z "${net_mac1}" ];then
        echo "cant get ${net_name}'s MAC'"
        exit 1
    fi
    sed -i "/GATEWAY/aHWADDR=${net_mac1}" ifcfg-eth1

    if [ ! -f bak_ifcfg-${net_name} ];then
        mv ifcfg-${net_name} bak_ifcfg-${net_name}
    fi
}

modify_grub(){
    cd /etc/sysconfig/
    if [ -e bak_grub ];then
        echo "bak_grup has already existed"
    else
        \cp /etc/sysconfig/grub /etc/sysconfig/bak_grub
    fi

cat <<EOF > /etc/sysconfig/grub
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="$(sed 's, release .*$,,g' /etc/system-release)"
GRUB_DEFAULT=saved
GRUB_DISABLE_SUBMENU=true
GRUB_TERMINAL_OUTPUT="console"
GRUB_CMDLINE_LINUX="crashkernel=auto rhgb quiet net.ifnames=0 biosdevname=0"
GRUB_DISABLE_RECOVERY="true"
EOF

    grub2-mkconfig -o /boot/grub2/grub.cfg
}

modify_rule(){
    cd /etc/udev/rules.d
    sudo rm -rf 70-persistent-net.rules
    touch 70-persistent-net.rules
    device0="eth0"
    device1=$(ls -l /sys/class/net |grep `lspci |grep "Ethernet controller" |awk '(NR==2){print $1}'` |awk -F"/" '{print $NF}')
    net_mac0=$(cat /sys/class/net/${device0}/address)
    net_mac1=$(cat /sys/class/net/${device1}/address)
    echo "SUBSYSTEM==\"net\",ACTION==\"add\",DRIVERS==\"?*\",ATTR{address}==\"${net_mac0}\",ATTR{type}==\"1\" ,KERNEL==\"eth*\",NAME=\"eth0\"" > 70-persistent-net.rules
    echo "SUBSYSTEM==\"net\",ACTION==\"add\",DRIVERS==\"?*\",ATTR{address}==\"${net_mac1}\",ATTR{type}==\"1\" ,KERNEL==\"eth*\",NAME=\"eth1\"" >> 70-persistent-net.rules

    #echo "HWADDR=${net_mac1}" >> /etc/sysconfig/network-scripts/ifcfg-eth1
    sed -i 's/ONBOOT=no/ONBOOT=yes/g' /etc/sysconfig/network-scripts/ifcfg-eth1
}

reboot(){
    read -r -p "Would you like to reboot this server? [Y|y/N|n] " input
    case $input in
        [yY][eE][sS]|[yY])
            echo "Your's answer is: Yes"
            shutdown -r now
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
}

reboot_quiet(){
    shutdown -r now
}


####main
check_service
hw_check
inspur_check
bak_net_conf
generate_eth1
modify_grub
modify_rule
#reboot
reboot_quiet
