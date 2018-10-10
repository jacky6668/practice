#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    6_iscsi_loop_add_remove_target.sh 
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
iqn="iqn.1991-05.com.microsoft:win-f6mhhocu2qn"
number=`seq 1 120 |sort -n`   ###Cycle number(create volume/access-path/mapping-group)


### create volume
create_vol()
{
for i in $number
do
    echo "create vol-$i ..."
    $cli block-volume create -p $pool_id -s 107374182400 -f 128 lun_v3_$1
    sleep 2
done
}

### Delete volume
delete_vol(){
   echo "delete vol"
   xms-cli  -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-volume list |\
   xargs -I {} sh -c  'xms-cli --user admin -p admin block-volume delete {}; sleep 3'
}


vol_list=(`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-volume list --limit -1`)
vol1=(`echo ${vol_list[0]} | tr [:space:] "," | sed 's/,$//g'`)
#vol2=(`echo ${vol_list[40]} | tr [:space:] "," | sed 's/,$//g'`)
#vol3=(`echo ${vol_list[80]} | tr [:space:] "," | sed 's/,$//g'`)
vol_id1=(`echo ${vol_list[@]:1:120} | tr [:space:] "," | sed 's/,$//g'`)
#vol_id2=(`echo ${vol_list[@]:41:39} | tr [:space:] "," | sed 's/,$//g'`)
#vol_id3=(`echo ${vol_list[@]:81:39} | tr [:space:] "," | sed 's/,$//g'`)


### Create client-group
create_client(){
echo "create client-group"
$cli client-group create --type iSCSI --codes "$iqn" iscsi_client
}

delete_client(){
echo "delete client-group"
xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin client-group list |\
xargs -I {} sh -c  'xms-cli --user admin -p admin client-group delete {}; sleep 5'
}

client_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin client-group list`

### Create path
create_ap(){
echo "create access-path"
${cli} access-path create --type iSCSI iscsi_path
sleep 2
}
ap_id=(`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin access-path list`)

delete_ap(){
echo "delete access-path"
xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin target list |\
xargs -I {} sh -c  'xms-cli --user admin -p admin access-path delete {}; sleep 5'
}

### Create target
create_target(){
echo "create target"
iscsi_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin access-path list`
$cli target create -a $iscsi_id --host 1
$cli target create -a $iscsi_id --host 2
$cli target create -a $iscsi_id --host 3
for i in {1..100}
    do
        sleep 1
        target_status=`xms-cli -f '{{range .}}{{println .status}}{{end}}' --user admin --password admin target list`
        if [[ $target_status = "active" ]]
        then
            break
        else
            continue
        fi
done
}

delete_target(){
echo "delete target"
xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin target list |\
xargs -I {} sh -c  'xms-cli --user admin -p admin target delete {}; sleep 5'
}


loop_tg(){
for i in {1..10}
do
delete_target
sleep 3
create_target
sleep 3
done
}

### create asset
create(){
create_vol
create_ap
create_target
check_stat
loop_tg
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

