#!/bin/bash

set -x

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

function set_ganesha_logrotate() {
    log_info "1.config logrotate of ganesha"
    cat  <<EOF > /etc/logrotate.d/ganesha
/export/jcloud-cfs/log/ganesha*.log {
    rotate 60
    size 1G
    compress
    missingok
    notifempty
}
EOF
}

function set_crontable() {
    log_info "2.config cron task of ganesha"
    echo "*/5 * * * * root /usr/sbin/logrotate /etc/logrotate.d/ganesha" > /etc/cron.d/ganesha
}

###main
log_info "You are setting rotation of ganesha log, which is idempotent."
set_ganesha_logrotate
set_crontable
log_info "Finished"
log_info "~~~~~~~~~~~~~~~~~~~"
