#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    17_1024_IscsiAp_1024_lun.sh
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
pool_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin pool list`
iqn=""
number=`seq 1 1024 |sort -n`   ###Cycle number(create volume/access-path/mapping-group)
client='10.252.252.3.137'

### Create volume
create_vol(){
echo "Create 1024 volume...."
for i in $num
do
    $cli block-volume create -p $pool_id -s 100g iscsi_v3_$i
done
echo "Create 1024 volume succeed!!"
sleep 300
}

vol_list=(`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-volume list --limit -1`)
vol1=(`echo ${vol_list[0]} | tr [:space:] "," | sed 's/,$//g'`)
vol2=(`echo ${vol_list[1]} | tr [:space:] "," | sed 's/,$//g'`)
vol3=(`echo ${vol_list[2]} | tr [:space:] "," | sed 's/,$//g'`)
#vol_id1=(`echo ${vol_list[@]:1:39} | tr [:space:] "," | sed 's/,$//g'`)
#vol_id2=(`echo ${vol_list[@]:41:39} | tr [:space:] "," | sed 's/,$//g'`)
#vol_id3=(`echo ${vol_list[@]:81:39} | tr [:space:] "," | sed 's/,$//g'`)


delete_vol(){
   echo "delete vol"
   xms-cli  -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-volume list |\
   xargs -I {} sh -c  'xms-cli --user admin -p admin block-volume delete {}; sleep 3'
}

## Create client-groups
create_client(){
echo "Create 1024 client groups..."
for i in $num
do
    $cli client-group create --type iSCSI --codes "$iqn$i" iscsi_client_$i
done
echo "Create 1024 client groups succeed!!"
sleep 240
}
client_list=(`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin client-group list`)
clien1=(`echo ${client_list[0]}`)
clien2=(`echo ${client_list[1]}`)
clien3=(`echo ${client_list[2]}`)


delete_client(){
echo "delete client-group"
xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin client-group list |\
xargs -I {} sh -c  'xms-cli --user admin -p admin client-group delete {}; sleep 5'
}

## Create access-path
create_ap(){
echo "Create 1024 access-path..."
for i in $num
do
    ${cli} access-path create --type iSCSI iscsi_path_$i
done
}
ap_list=(`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin access-path list --limit -1`)
ap1=(`echo ${ap_list[0]}`)
ap2=(`echo ${ap_list[1]}`)
ap3=(`echo ${ap_list[2]}`)

delete_ap(){
echo "delete access-path"
xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin target list |\
xargs -I {} sh -c  'xms-cli --user admin -p admin access-path delete {}; sleep 5'
}

## Create target
create_target(){
iscsi_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin access-path list`
for i in $iscsi_id
do
    $cli target create -a $i --host 1
    $cli target create -a $i --host 2
    $cli target create -a $i --host 3
    sleep 3
done
}

delete_target(){
echo "delete target"
xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin target list |\
xargs -I {} sh -c  'xms-cli --user admin -p admin target delete {}; sleep 5'
}

## Create mapping-group
create_mp(){
for i in {3..1023}
$cli mapping-group create -a $ap_id$i -v $vol$i -c $client$i
sleep 5
}

### Client add io
client_io(){
echo "Remote find and mount the volume, plus IO"
ssh root@$client "sh /root/much_iscsi.sh;exit 0"
ssh root@$client "fio /root/much.block 1>&- 2>&- &;exit 0"
}

### Stop io
client_stop_io(){
ssh root@$client "sh /root/stop_io.sh 1>&- 2>&- &"
}

### Create
create(){
create_vol
create_client
create_ap
create_target
create_mp
client_io
}

### Delete
delete(){
client_stop_io
sleep 15
delete_mp
delete_target
delete_ap
delete_client
delete_vol
check_stat
}


################ main ################
create
#delete






