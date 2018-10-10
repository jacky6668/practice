#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    2_create_iscsi_at.sh
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
# Delete volume
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
sleep 5
}

delete_target(){
echo "delete target"
xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin target list |\
xargs -I {} sh -c  'xms-cli --user admin -p admin target delete {}; sleep 5'
}

### Create mapping-group
create_mp(){
echo "create mp..."
$cli mapping-group create -a ${ap_id[0]} -v ${vol1} -c $client_id
sleep 10
echo "create success"
}

add_mp_lun(){
echo "Add vol to mapping-group"
mp_id=(`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin mapping-group list`)
$cli mapping-group add block-volume  ${mp_id[0]} ${vol_id1}
sleep 120
echo "Volume added success"
}

delete_mp(){
xms-cli  -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin mapping-group list |\
xargs -I {} sh -c  'xms-cli --user admin -p admin mapping-group delete {}; sleep 5'
sleep 120
}

## check status
check_stat(){
xdcadm -L at -m at -o show
xdcadm -L at -m lun -o show
xdcadm -L at -m sys -o show
}

### Create
create(){
create_vol
create_ap
create_target
create_mp
add_mp_lun
check_stat
}

### Delete
delete(){
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
