#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    15_set_performance_priority_remove_lun.sh
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
mp_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin mapping-group list`
$cli mapping-group add block-volume $mp_id $vol_id
}

remove_mp_lun(){
mp_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin mapping-group list`
$cli mapping-group remove block-volume $mp_id $vol_id
sleep 10
}

### Set performance_priority
set_high_speed_vol(){
vol_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-volume list` 
$cli block-volume set --performance-priority 1 $vol_id
sleep 8
}

## Remote find and mount the volume, plus IO
client_io(){
echo "Remote find and mount the volume, plus IO"
ssh root@$client "sed -i 's/^#to_io$/to_io/g' iscsi_discovery_mount.sh"
ssh root@$client "sh /root/iscsi_discovery_mount.sh"
sleep 10
### check io status
echo "check io status..."
for i in {1..10000}
do
    io_s=`ceph -s|grep client`
#    read_io=`echo $io_s|awk '{print $5}'`
    write_io=`echo $io_s|awk '{print $11}'`
    echo "read_io:$read_io"
    if [ $read_io != "0" ]
    then
        echo "IO status ok!!"
        break
    else
        continue
    fi
done
sleep 10
for i in {1..100000}
do
    io_s=`ceph -s|grep client`
#    read_io=`echo $io_s|awk '{print $5}'`
    write_io=`echo $io_s|awk '{print $11}'`
    echo "read_io:$read_io"
    if [ $read_io = "0" ]
    then
        echo "io is:0"
        break
    else
        continue
    fi
done
ssh root@$client "sed -i 's/^to_io$/#to_io/g' iscsi_discovery_mount.sh && sed -i 's/^#to_read$/to_read/g' iscsi_discovery_mount.sh"
ssh root@$client "sh /root/iscsi_discovery_mount.sh"
}

#ssh root@$client "sed -i 's/^#randrw_io$/randrw_io/g' iscsi_discovery_mount.sh && sed -i 's/^read_io$/#read_io/g' iscsi_discovery_mount.sh "
#sed -i 's/^#read_io$/read_io/g' iscsi_discovery_mount.sh "


### remove lun
remove_lun(){
echo "Remove volume..."
$cli mapping-group remove block-volume $mapping_id $vol_id
sleep 6
}

### stop io
client_stop_io(){
ssh root@$client "sh /root/stop_io.sh 1>&- 2>&- &"
}

### Create
create(){
create_vol
create_ap
create_target
create_mp
set_high_speed_vol
client_io
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
