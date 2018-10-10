#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    10_iscsi_io_remov_target.sh
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
number=`seq 1 4 |sort -n`   ###Cycle number(create volume/access-path/mapping-group)
client='10.252.3.35'

### Create vol
create_vol()
{
#for i in $number
#do
#    $cli block-volume create -p $pool_id -s 107374182400 -f 128 lun_v3_$i
#done
$cli block-volume create -p $pool_id -s 107374182400 -f 128 lun_v3
}
vol_list=(`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-volume list --limit -1`)
vol1=(`echo ${vol_list[0]} | tr [:space:] "," | sed 's/,$//g'`)
vol_id1=(`echo ${vol_list[@]:1:3} | tr [:space:] "," | sed 's/,$//g'`)

delete_vol(){
   echo "delete vol"
   xms-cli  -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-volume list |\
   xargs -I {} sh -c  'xms-cli --user admin -p admin block-volume delete {}; sleep 3'
}

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
ap_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin access-path list`

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
#$cli mapping-group create -a ${ap_id[0]} -v ${vol1} -c $client_id
vol_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-volume list`
$cli mapping-group create -a $ap_id -v $vol_id -c $client_id
sleep 10
echo "create success"
}

add_mp_lun(){
echo "Add vol to mapping-group"
mp_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin mapping-group list`
$cli mapping-group add block-volume  $mp_id ${vol_id1}
sleep 120
echo "Volume added success"
}

## Remote find and mount the volume, plus IO
client_io(){
echo "Remote find and mount the volume, plus IO"
ssh root@$client "sh /root/iscsi_discovery_mount.sh 1>&- 2>&- &"
sleep 10
### check io status
echo "check io status..."
for i in {1..10000}
do
    io_s=`ceph -s|grep client`
    read_io=`echo $io_s|awk '{print $8}'`
    write_io=`echo $io_s|awk '{print $11}'`
    if [ $read_io != "0" ] || [  $write_io != "0" ]
    then
        echo "IO status ok!!"
        break
    else
        continue
    fi
done
}

### remove target
remove_target(){
iscsi_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin access-path list -q "type:iSCSI" -q "name:iscsi_path"`
echo "Remove target..."
for i in {1..20}
do
    target_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin target list|shuf -n1|awk '{print $1}'`
    host_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin target list|sed -n '/^"'$id'"/p'|awk '{print $2}'`
    $cli target delete $target_id
    number_tar=`xms-cli -f '{{range .}}{{println .status}}{{end}}' --user admin --password admin target list|wc -l`
    echo $target_id
    if [ $number_tar = 2 ]
    then
        echo "Remove target succeed!"
        break
    else
        continue
    fi
    sleep 30 
    $cli target create -a $iscsi_id --host $host_id
done
}

client_stop_io(){
ssh root@$client "sh /root/stop_io.sh 1>&- 2>&- &"
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
client_io
remove_target
check_stat
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
