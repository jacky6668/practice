#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    18_iscsi_local_255_lun.sh
# Revision:    1.0
# Date:        2018/08/12
# Author:      yangyang
# Email:       yangyang@xsky.com
# Description: Build 3 local ap with multi vols
# Notes:       This plugin uses the "" command
# -------------------------------------------------------------------------------
# Copyright:   2018 (c) yangyang

cli="xms-cli --user admin --password admin"
num=`seq 1 1024`
pool_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin pool list -q "name:test_pool"`
iqn="iqn.1994-05.com.redhat:f2cdaa8fbbeb"
client_name="iscsi_client"

### Create volume
create_vol(){
echo "Create 1024 volume...."
for i in $num
do
    sleep 1
    $cli block-volume create -p $pool_id -s 10g lun_v3_$i
done
echo "Create 1024 volume succeed!!"
sleep 10
}
vol_list=(`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-volume list --limit -1`)
vol1=(`echo ${vol_list[0]} | tr [:space:] "," | sed 's/,$//g'`)
vol2=(`echo ${vol_list[1]} | tr [:space:] "," | sed 's/,$//g'`)
vol3=(`echo ${vol_list[2]} | tr [:space:] "," | sed 's/,$//g'`)
vol4=(`echo ${vol_list[3]} | tr [:space:] "," | sed 's/,$//g'`)
vol_id1=(`echo ${vol_list[@]:4:254} | tr [:space:] "," | sed 's/,$//g'`)
vol_id2=(`echo ${vol_list[@]:259:254} | tr [:space:] "," | sed 's/,$//g'`)
vol_id3=(`echo ${vol_list[@]:513:254} | tr [:space:] "," | sed 's/,$//g'`)
vol_id4=(`echo ${vol_list[@]:767:254} | tr [:space:] "," | sed 's/,$//g'`)

delete_vol(){
   echo "delete vol"
   xms-cli  -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-volume list |\
   xargs -I {} sh -c  'xms-cli --user admin -p admin block-volume delete {}; sleep 1'
}

### Create client-groups
create_client(){
echo "Create client groups..."
$cli client-group create --type iSCSI --codes "$iqn" $client_name
echo "Create  client groups succeed!!"
sleep 10
}
client_id=`xms-cli -f '{{range .}}{{println .id .name}}{{end}}' --user admin --password admin client-group list`

delete_client(){
echo "delete client-group"
xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin client-group list |\
xargs -I {} sh -c  'xms-cli --user admin -p admin client-group delete {}; sleep 5'
}

### Create local access-path
create_local_ap(){
echo "Create local access-path..."
for i in $(seq 1 3)
do
    echo $i
    ${cli} access-path create --type Local local_path_$i
    echo "Create local  access-path succeed!!!"
done
sleep 10
}

### Create iscsi access-path
#${cli} access-path create --type iSCSI iscsi_path_1
create_iscsi_ap(){
echo "Create iscsi access-path...."
${cli} access-path create --type iSCSI iscsi_path
}

### Delete access-path
delete_ap(){
xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin target list |\
xargs -I {} sh -c  'xms-cli --user admin -p admin access-path delete {}; sleep 5'
}


### Create target
create_target(){
iscsi_id=`xms-cli -f '{{range .}}{{println .id .name}}{{end}}' --user admin --password admin access-path list -q "name:iscsi_path"`
local_1=`xms-cli -f '{{range .}}{{println .id .name}}{{end}}' --user admin --password admin access-path list -q "local_path_1"`
local_2=`xms-cli -f '{{range .}}{{println .id .name}}{{end}}' --user admin --password admin access-path list -q "local_path_2"`
local_3=`xms-cli -f '{{range .}}{{println .id .name}}{{end}}' --user admin --password admin access-path list -q "local_path_3"`
sleep 5
$cli target create -a $local_1 --host 1
$cli target create -a $local_2 --host 2
$cli target create -a $local_3 --host 3
$cli target create -a $iscsi_id --host 1
$cli target create -a $iscsi_id --host 2
$cli target create -a $iscsi_id --host 3
sleep 6
}

delete_target(){
echo "delete target"
xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin target list |\
xargs -I {} sh -c  'xms-cli --user admin -p admin target delete {}; sleep 3'
}

### Create mapping-group  3
create_mp(){
$cli mapping-group create -a $local_1 -v $vol1
$cli mapping-group create -a $local_2 -v $vol2
$cli mapping-group create -a $local_3 -v $vol3
$cli mapping-group create -a $iscsi_id -v $vol4 -c $client_id
sleep 
}
mp_id=(`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin mapping-group list`)

### Add volume to mapping-group
add_mp_vol(){
$cli mapping-group add block-volume $iscsi_id ${vol_id1}
$cli mapping-group add block-volume $local_1 ${vol_id2}
$cli mapping-group add block-volume $local_2 ${vol_id3}
$cli mapping-group add block-volume $local_3 ${vol_id4}
}


delete_mp(){
    xms-cli  -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin mapping-group list |\
    xargs -I {} sh -c  'xms-cli --user admin -p admin mapping-group delete {}; sleep 5'
    sleep 60
}



### create cluster
create() {
create_vol
create_client
create_ap
create_target
create_mp
add_mp_vol
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

