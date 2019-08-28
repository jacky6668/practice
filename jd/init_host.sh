#!/bin/bash

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

function mk_dir() {
    log_info "check CFS path"
    mkdir -p /export/jcloud-cfs/bin
    mkdir -p /export/jcloud-cfs/conf
    mkdir -p /export/jcloud-cfs/log
    mkdir -p /export/jcloud-cfs/core-file
}

function set_bashrc() {
    log_info "rewrite ~/.basrc"
    cat << EOF > ~/.bashrc
# User specific aliases and functions

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi
alias rm='mv -f --target-directory=/export/.trash/'
alias vi='vim'
ulimit -c unlimited
export GOTRACEBACK=crash
EOF
}

function set_core_pattern() {
    log_info "set core pattern"
    echo "/export/jcloud-cfs/core-file/core-%e-%p-%t" > /proc/sys/kernel/core_pattern
}

# main
log_info "You are initialzing OS config, which is idempotent."
mk_dir
set_bashrc
set_core_pattern
log_info "Finished"
log_info "~~~~~~~~~~~~~~~~~~~"
