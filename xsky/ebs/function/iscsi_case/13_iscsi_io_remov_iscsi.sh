#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    13_iscsi_io_remov_iscsi.sh
# Revision:    1.0
# Date:        2018/08/11
# Author:      yangyang
# Email:       yangyang@xsky.com
# Description: Build 3 local ap with multi vols
# Notes:       This plugin uses the "" command
# -------------------------------------------------------------------------------
# Copyright:   2018 (c) yangyang

### Variable Comments
cli=`cli="xms-cli --user admin --password admin"`
pool_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin pool list -q "name:HybirdPool"`
number=`seq 1 120 |sort -n`   ###Cycle number(create volume/access-path/mapping-group)

### Create volume,
create_vol()
{
#for i in $number
#do
#    $cli block-volume create -p $pool_id -s 107374182400 -f 128 lun_v3_$1
#    sleep 2
#done
$cli block-volume create -p $pool_id -s 107374182400 -f 128 lun_v3
}

# Delete volume
delete_vol(){
   xms-cli  -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-volume list |\
   xargs -I {} sh -c  'xms-cli --user admin -p admin block-volume delete {}; sleep 3'
}


reate access-path
create_ap(){
#for i in {1..3}
#do
#   $cli access-path create --type iSCSI local_$i
#   sleep 2
#done
$cli access-path create --type iSCSI iscsi_path
}

### Create target
create_target(){
ap_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin access-path list`
echo $ap_id
echo $host_id
$cli target create -a $ap_id --host 1
$cli target create -a $ap_id --host 2
$cli target create -a $ap_id --host 3
sleep 5
}

delete_target(){
    xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin target list |\
    xargs -I {} sh -c  'xms-cli --user admin -p admin target delete {}; sleep 5'
    sleep 15
}

create_mp(){
echo "create mp..."
#$cli mapping-group create -a ${ap_id[0]} -v ${vol1} -c $client_id
vol_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-volume list`
$cli mapping-group create -a $ap_id -v $vol_id -c $client_id
sleep 10
echo "create success"
}
mp_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin mapping-group list`

delete_ap(){
xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin access-path list |\
    xargs -I {} sh -c  'xms-cli --user admin -p admin access-path delete {}; sleep 5'
    sleep
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
sleep 2
}

### Remove mapping-group
remove_mp(){
echo "Remove volume..."
$cli mapping-group delete $mp_id
sleep 6
}

### loop
loop_mp(){
for i in {1..10}
do
remove_mp
sleep 10
create_mp
sleep 10
done
}

##check status
print_status(){
xdcadm -L at -m at -o show
xdcadm -L at -m lun -o show
xdcadm -L at -m sys -o show
}

### create asset
create(){
create_vol
create_client
create_ap
create_target
create_mp
client_io
sleep 10
loop_mp
print_status
}

### delete asset
delete(){
client_stop_io
sleep 10
delete_mp
delete_target
delete_ap
delete_vol
}

####### main ######
create
#delete
