#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    template_of_shell.sh
# Revision:    1.0
# Date:        2019/12/10
# Author:      Yibo Chan
# Email:       yibo.com
# Website:     www.ohlinux.com
# Description: Plugin to monitor the memory of the system
# Notes:       This plugin uses the "" command
# Copyright:   2009 (c) Ajian
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

usage() {
    printf "usage:$0 <${GREEN} ahead | back ${NC}>\n"
    printf "\t${YELLOW}ahead${NC}: change from local to etcd\n"
    printf "\t${YELLOW}back${NC}: change from etcd to local\n"
}

function log_info() {
    if [ ! -d /export/jcloud-cfs/log ]
    then
        mkdir -p /export/jcloud-cfs/log
    fi

    DATE_N=`date "+%Y-%m-%d %H:%M:%S"`
    USER_N=`whoami`
    echo "${DATE_N} ${USER_N} execute $0 [INFO] $@" >> /export/jcloud-cfs/log/op.log
}

function log_error() {
    DATE_N=`date "+%Y-%m-%d %H:%M:%S"`
    USER_N=`whoami`
    echo -e "\033[41;37m ${DATE_N} ${USER_N} execute $0 [ERROR] $@ \033[0m"  >> /export/jcloud-cfs/log/op.log
}

function fn_log()  {
    cmd = $@
    re = `${cmd}`
    if [  re -eq 0  ]
    then
        log_info "$@ sucessed."
        echo -e "\033[32m $@ sucessed. \033[0m"
    else
        log_error "$@ failed."
        echo -e "\033[41;37m $@ failed. \033[0m"
        exit 1
    fi
}

fn1() {
    echo "~~~(1/21)check dns~~~"
}

fn2() {
    echo "~~~(1/21)check dns~~~"
}


####main
if [ $# -ne 1 ]; then
    usage
    exit
fi

arg=${1}
case ${arg} in
    ahead)
        fn1
        ;;
    back)
        fn2
        ;;
    *)
        printf "${RED}args are wrong${NC}\n"
        usage
        ;;
esac
