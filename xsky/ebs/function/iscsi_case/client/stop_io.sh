#!/bin/bash
stop_io(){
ps -ef|grep "iscsi_discovery_mount.sh"|grep -v grep|cut -c 9-15|xargs kill -9 1>&- 2>&- &
ps -ef|grep "much_lun.block"|grep -v grep|cut -c 9-15|xargs kill -9  1>&- 2>&- &
sleep 5
}
logout_scsi(){
multipath -F
sleep 10
iscsiadm -m node all --logout
sleep 2
iscsiadm -m node -o delete
sleep 1
iscsiadm -m node
}


arg=${1}
case ${arg} in
    stop)
        stop_io
    ;;
         
    logout)
        logout_scsi
    ;;
    *)
        echo -e "\033[36m Lack of necessary parameters: \033[0m""\033[31m stop or logout !!! \033[0m"
esac
