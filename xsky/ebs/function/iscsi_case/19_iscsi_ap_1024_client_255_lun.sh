#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    19_iscsi_ap_1024_client_255_lun.sh
# Revision:    1.0
# Date:        2018/08/12
# Author:      yangyang
# Email:       yangyang@xsky.com
# Description: Build 3 local ap with multi vols
# Notes:       This plugin uses the "" command
# -------------------------------------------------------------------------------
# Copyright:   2018 (c) yangyang

### Variable Comments
cli="xms-cli --user admin --password admin"
pool_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin pool list -q "name:test_pool"`
iqn="iqn.1994-05.com.redhat:f2cdaa8fbbeb"
client_name="iscsi_client"

### Create volume
create_vol(){
echo "Create 255 volume...."
for i in $num
do
    sleep 1
    $cli block-volume create -p $pool_id -s 10g lun_v3_$i
done
echo "Create 255 volume succeed!!"
sleep 10
}

delete_vol(){
   echo "delete vol"
   xms-cli  -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-volume list |\
   xargs -I {} sh -c  'xms-cli --user admin -p admin block-volume delete {}; sleep 3'
}

### Create client-group
create_client(){
echo "Create client groups..."
#$cli client-group create --type iSCSI --codes "$iqn" $client_name
for i in {1..1024}
do
    $cli client-group create --type iSCSI --codes "$iqn"$i $client_name$i
done
sleep 30
}

delete_client(){
echo "delete client-group"
xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin client-group list |\
xargs -I {} sh -c  'xms-cli --user admin -p admin client-group delete {}; sleep 5'
}reate iscsi access-path
$cli access-path create --type iSCSI iscsi_path_1
sleep 5

### Create target
create_target(){
iscsi_id=`xms-cli -f '{{range .}}{{println .id .name}}{{end}}' --user admin --password admin access-path list -q "name:iscsi_path_1"`
$cli target create -a $iscsi_id --host 1
$cli target create -a $iscsi_id --host 2
$cli target create -a $iscsi_id --host 3
sleep 5
}

### Create mapping-group...
create_mp(){
for i in {1..255}
do
    vol_id=`xms-cli -f '{{range .}}{{println .id .name}}{{end}}' --user admin --password admin block-volume list|grep "lun_v3_$i$"|awk '{print $1}'`
    client_id=`xms-cli -f '{{range .}}{{println .id .name}}{{end}}' --user admin --password admin client-group list|grep "iscsi_client$i$"|awk '{print $1}'`
    $cli mapping-group create -a $iscsi_id -v $vol_id -c $client_id
done
}

delete_mp(){
    xms-cli  -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin mapping-group list |\
    xargs -I {} sh -c  'xms-cli --user admin -p admin mapping-group delete {}; sleep 5'
    sleep 300
}


### create cluster
create() {
create_vol
create_client
create_ap
create_target
create_mp
}

### delete cluster
delete() {
delete_mp
delete_target
delete_ap
delete_client
delete_vol
}


#### main
create
#delete



