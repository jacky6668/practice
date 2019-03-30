#!/bin/bash

set -x

ipaddr=()
downtime=60
uptime=300

check_kill(){
    echo check kill status
    pid=$(ssh root@$1 "ps aux | grep $2 | grep -v grep | grep -v $2.log | awk  '{print \$2}'")
    echo pid is $pid
    if [ $pid ];then
        echo service $2 exists,WRONG,exit now
        exit 1
    else
        echo service $2 not exists, OK
    fi
}

check_start(){
    echo check start status
    pid=$(ssh root@$1 "ps aux | grep $2 | grep -v grep | grep -v $2.log | awk  '{print \$2}'")
    echo pid is $pid
    if [ $pid ];then
        echo service $2 exists, OK
    else
        echo service $2 NOT exsits, WRONG, exit now
        exit 1
    fi
}


manager() {
    date=$(date +%Y%m%d%H%M)
    check_start $1 wos-manager
    echo stop $1 manger at ${date}
    ssh root@$1 "ps aux | grep wos-manager | grep -v grep | awk  '{print \$2}' | xargs -I {} kill -9 {}"
    sleep ${downtime}

    date=$(date +%Y%m%d%H%M)
    check_kill $1 wos-manager
    echo start $1 manager at ${date}
    ssh root@$1 "nohup /export/jcloud-cfs/bin/wos-manager --config=/export/jcloud-cfs/conf/wos-manager.cfg > /export/jcloud-cfs/log/wos-manager.out${date} 2>&1 &"
    sleep ${uptime}
}

mds() {
    date=$(date +%Y%m%d%H%M)
    check_start $1 cfs-mds
    echo stop $1 mds at ${date}
    ssh root@$1 "ps aux | grep cfs-mds | grep -v grep | awk  '{print \$2}' | xargs -I {} kill -9 {}"
    sleep ${downtime}

    date=$(date +%Y%m%d%H%M)
    check_kill $1 cfs-mds
    echo start $1 mds at ${date}
    ssh root@$1 "nohup /export/jcloud-cfs/bin/cfs-mds -config /export/jcloud-cfs/conf/cfs-mds.cfg > /export/jcloud-cfs/log/cfs-mds.out${date} 2>&1 &"
    sleep ${uptime}
}

node() {
    date=$(date +%Y%m%d%H%M)
    check_start $1 wos-node
    echo stop $1 node at ${date}
    ssh root@$1 "ps aux | grep wos-node | grep -v grep | awk  '{print \$2}' | xargs -I {} kill -9 {}"
    sleep ${downtime}

    date=$(date +%Y%m%d%H%M)
    check_kill $1 wos-node
    echo start $1 node at ${date}
    ssh root@$1 "nohup /export/jcloud-cfs/bin/wos-node --config=/export/jcloud-cfs/conf/wos-node.cfg > /export/jcloud-cfs/log/wos-node.out${date} 2>&1 &"
    sleep ${uptime}
}

client() {
    date=$(date +%Y%m%d%H%M)
    check_start $1 cfs-clt
    echo stop $1 client at ${date}
    ssh root@$1 "ps aux | grep cfs-clt | grep -v grep | awk  '{print \$2}' | xargs -I {} kill -9 {}"
    sleep ${downtime}

    date=$(date +%Y%m%d%H%M)
    check_kill $1 cfs-clt
    echo start $1 client at ${date}
    ssh root@$1 "nohup /export/jcloud-cfs/bin/cfs-clt -config /export/jcloud-cfs/conf/cfs-clt.cfg > /export/jcloud-cfs/log/cfs-clt.out${date} 2>&1 &"
    sleep ${uptime}
}

ganesha() {
    echo stop $1 ganesha at ${date}
    check_start $1 ganesha
    ssh root@$1 "ps aux | grep ganesha | grep -v grep | awk  '{print \$2}' | xargs -I {} kill -9 {}"
    sleep ${downtime}

    date=$(date +%Y%m%d%H%M)
    check_kill $1 ganesha
    echo start $1 ganesha at ${date}
    ssh root@$1 "/export/jcloud-cfs/install/ganesha/usr/bin/ganesha.nfsd -f /export/jcloud-cfs/install/ganesha/etc/ganesha/ganesha.conf"
    sleep ${uptime}
}

service1=(mds manager)
service2=(client node)

for i in {1..100000}
do
    echo ********start $i times at `date`*********
    index=$(($RANDOM%${#ipaddr[@]}))
    ip=${ipaddr[$index]}
    echo ${ip}

    if [ $ip = "192.168.245.44" ];then
       index1=$(($RANDOM%${#service1[@]}))
       ser=${service1[$index1]}
       $ser $ip
    else
       index2=$(($RANDOM%${#service2[@]}))
       ser=${service2[$index2]}
       $ser $ip
    fi
done
