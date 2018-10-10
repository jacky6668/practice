#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    login_and_logout
# Revision:    1.0
# Date:        2018/08/15
# Author:      yibo
# Email:       yibo@xsky.com
# Description: iscsi initionator login or logou
# Notes:       This plugin uses the "" command
# -------------------------------------------------------------------------------
# Copyright:   2018 (c) yibo


host="
10.252.2.198
10.252.2.199
10.252.2.200
"

### usage
usage() {
echo "./login_and_logout <in|out>"
}

### login
iscsi_login() {
for i in ${host} 
do
    iscsiadm -m discovery -t st -p ${i}
    sleep 1
done
iscsiadm -m node --login
sleep 3
multipath -F
sleep 1
multipath -v3
sleep 1
multipath -ll
}

### login
iscsi_logout() {
multipath -F
iscsiadm -m node --logout
sleep 1
iscsiadm -m node --op delete
}


#### main
arg=${1}
case ${arg} in
    in)
        iscsi_login
    ;;
    out)
        iscsi_logout
    ;;
    *)
        echo "args are wrong"
        usage
    ;;
esac

