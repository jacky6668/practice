#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    Change_RAID0_JBOD.sh
# Revision:    1.0
# Date:        2021/02/02
# Author:      Yibo Chan
# Email:       chenyibo2@jd.com
# Description: Change ssd mode from raid0 to JBOD.
# Notes:
# Copyright:   2021
# License:     GPL
# -------------------------------------------------------------------------------

####color
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

slot_root=""
slot_list=""
key_word="zbs|cfs|wos|ha-monitor|ha-agent|docker|qemu|nbd"

check_file() {
    # check magacli
    if [ -f '/usr/bin/MegaCli' ];then
        printf "${GREEN}MegaCli check pass.${NC}\n"
    else
        printf "${RED}There is no MegaCli in /usr/bin!!!${NC}\n"
        exit 1
    fi
}

check_process() {
    # check zbs|cfs process
    local re=$(ps axf | grep -E ${key_word} | grep -v grep)
    if [ ${#re} -eq 0 ];then
        printf "${GREEN}process check pass.${NC}\n"
    else
        printf "${RED}There is some process running!!!${NC}\n"
        echo "${re}"
        exit 1
    fi
}

get_root_slot() {
    # get slot and path of /
    local dev1=$(mount | grep "on / type" | grep -Po "sd[a-z]")
    local dev2=$(lsblk | grep -E '\/$' | grep -Po sd[a-z])

    if [ -z "${dev1}" ] || [ -z "{dev2}" ];then
        printf "${RED}Cant get slot of root path!!!${NC}\n"
        echo "dev1 is ${dev1}, and dev2 is ${dev2}"
        exit 1
    elif [ ${dev1}X != ${dev2}X ];then
        printf "${RED}Name of root path is WRONG!!!${NC}\n"
        echo "dev1 is ${dev1}, and dev2 is ${dev2}"
        exit 1
    else
        printf "${GREEN}root check pass.${NC}\n"
    fi

    local root_size=$(lsblk | grep -E "\<${dev1}\>" | awk -F ' ' '{print$4}' |
        grep -Po "[0-9]+.[0-9]+")
    slot_root=$(MegaCli -LDInfo -Lall -aALL | grep -B 5 "${root_size}" |
        grep -Po "Id: \d+" | awk -F ' ' '{print$2}')
}

get_slot() {
    # get slots of data disks
    slot_list=$(ls -l /sys/block/* | grep -E sd[a-z] | grep -v sda |
                grep -Po "target.*/" | awk -F '/' '{print$1}' |
                awk -F ':' '{print$NF}')

    # check slot
    local re=$(echo ${slot_list} | grep -E "\<${slot_root}\>")
    if [[ "${re}"X != ''X ]];then
        printf "${RED}The slot of root is in formate list!!!${NC}\n"
        echo "slot_list is ${slot_list}"
        echo "slot_root is ${slot_root}"
        exit 1
    else
        printf "${GREEN}slot check pass.${NC}\n"
    fi
}

format_JBOD() {
    # delete raid0
    echo "=====NOW FORMAT JBOD====="
    for i in ${slot_list}
    do
        echo "NOW delet slot $i"
        MegaCli -cfglddel -L$i -force -a0;
    done
    sleep 1

    # format to JBOD
    MegaCli -AdpSetProp -EnableJBOD -1 -a0
    sleep 1

    # check mode
    for i in ${slot_list}
    do
        local mode=$(MegaCli -pdlist -a0 | grep -A 20 -E "\<Slot Number: ${i}\>"|
               grep "Firmware state" | awk -F ' ' '{print$3}')
        if [[ ${mode}X == "JBOD"X ]];then
            printf "${GREEN}mode check pass.${NC}\n"
        else
            printf "${RED}The mode of slot ${i} is WRONG!!!${NC}\n"
            exit 1
        fi
    done
}


#########main#########
check_file
check_process
get_root_slot
get_slot
format_JBOD
