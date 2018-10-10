#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    1_create_local_at.sh
# Revision:    1.0
# Date:        2018/08/11
# Author:      yangyang
# Email:       yangyang@xsky.com
# Description: Build 3 local ap with multi vols
# Notes:       This plugin uses the "" command
# -------------------------------------------------------------------------------
# Copyright:   2018 (c) yangyang

### Variable Comments
cli="xms-cli --user admin --password admin"
pool_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin pool list -q "name:HybirdPool"`
number=`seq 1 120 |sort -n`   ###Cycle number(create volume/access-path/mapping-group)

### Create volume,
create_vol()
{
for i in $number
do
    $cli block-volume create -p $pool_id -s 107374182400 -f 128 lun_v3_$1
    sleep 2
done
}
# Delete volume
delete_vol(){
   xms-cli  -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-volume list |\
   xargs -I {} sh -c  'xms-cli --user admin -p admin block-volume delete {}; sleep 3'
}


vol_list=(`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-volume list --limit -1`)
vol1=(`echo ${vol_list[0]} | tr [:space:] "," | sed 's/,$//g'`)
vol2=(`echo ${vol_list[40]} | tr [:space:] "," | sed 's/,$//g'`)
vol3=(`echo ${vol_list[80]} | tr [:space:] "," | sed 's/,$//g'`)
vol_id1=(`echo ${vol_list[@]:1:39} | tr [:space:] "," | sed 's/,$//g'`)
vol_id2=(`echo ${vol_list[@]:41:39} | tr [:space:] "," | sed 's/,$//g'`)
vol_id3=(`echo ${vol_list[@]:81:39} | tr [:space:] "," | sed 's/,$//g'`)


### Create access-path
create_ap(){
for i in {1..3}
do
   $cli access-path create --type Local local_$i
   sleep 2
done
}

delete_ap(){
xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin access-path list |\
    xargs -I {} sh -c  'xms-cli --user admin -p admin access-path delete {}; sleep 5'
    sleep 
}

### Create target
create_target(){
ap_id=(`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin access-path list`)
host_id=(`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin host list`)
echo $ap_id
echo $host_id
$cli target create -a ${ap_id[0]} --host ${host_id[0]}
$cli target create -a ${ap_id[1]} --host ${host_id[1]}
$cli target create -a ${ap_id[2]} --host ${host_id[2]}
sleep 5
}

delete_target(){
    xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin target list |\
    xargs -I {} sh -c  'xms-cli --user admin -p admin target delete {}; sleep 5'
    sleep 15
}

### create mapping-group
create_mp(){
echo "create mp..."
$cli mapping-group create -a ${ap_id[0]} -v ${vol1}
$cli mapping-group create -a ${ap_id[1]} -v ${vol2}
$cli mapping-group create -a ${ap_id[2]} -v ${vol3}
sleep 10
}
add_mp_lun(){
mp_id=(`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin mapping-group list`)
$cli mapping-group add block-volume  ${mp_id[0]} ${vol_id1}
$cli mapping-group add block-volume  ${mp_id[1]} ${vol_id2}
$cli mapping-group add block-volume  ${mp_id[2]} ${vol_id3}
}

### delete mapping-group
delete_mp(){
    xms-cli  -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin mapping-group list |\
    xargs -I {} sh -c  'xms-cli --user admin -p admin mapping-group delete {}; sleep 5'
    sleep 60
}

##chenk status
print_status(){
xdcadm -L at -m at -o show
xdcadm -L at -m lun -o show
xdcadm -L at -m sys -o show
}

### create asset
create(){
create_vol
create_ap
create_target
create_mp
}

### delete asset
delete(){
delete_mp
delete_target
delete_ap
delete_vol
}

####### main ######
create
#delete
