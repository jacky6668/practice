#/bin/bash
# -------------------------------------------------------------------------------
# Filename:    20_many_pools_1pool_full.sh
# Revision:    1.0
# Date:        2018/08/15
# Author:      yangyang
# Email:       yangyang@xsky.com
# Description: Build 3 local ap with multi vols
# Notes:       This plugin uses the "" command
# -------------------------------------------------------------------------------
# Copyright:   2018 (c) yangyang

### Variable Comments
cli="xms-cli --user admin --password admin"
ssd_id=`xms-cli -f '{{range .}}{{println .id }}{{end}}' --user admin --password admin pool list -q "name:ssd_pool"`
hybird_id=`xms-cli -f '{{range .}}{{println .id }}{{end}}' --user admin --password admin pool list -q "name:Hybird_pool"`
hdd_id=`xms-cli -f '{{range .}}{{println .id }}{{end}}' --user admin --password admin pool list -q "name:hdd_pool"`
qn="iqn.1994-05.com.redhat:f2cdaa8fbbeb"
client_name="iscsi_client"


### Create vol
create_vol(){
$cli block-volume create -p $ssd_id -s 100g -f 128 lun_v3_1
$cli block-volume create -p $ssd_id -s 100g -f 128 lun_v3_2
}
vol_list=(`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-volume list --limit -1`)

delete_vol(){
for i in $vol_list
do
$cli block-volume delete $i
done
}

### Create client-group
create_client(){
echo "Create client groups..."
$cli client-group create --type iSCSI --codes "$iqn" $client_name
echo "Create  client groups succeed!!"
sleep 10
}
client_id=`xms-cli -f '{{range .}}{{println .id }}{{end}}' --user admin --password admin client-group list`

delete_client(){
echo "delete client-group"
xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin client-group list |\
xargs -I {} sh -c  'xms-cli --user admin -p admin client-group delete {}; sleep 5'
}


### Create iscsi access-path
create_ap(){
${cli} access-path create --type iSCSI iscsi_path
}
ap_id=`xms-cli -f '{{range .}}{{println .id }}{{end}}' --user admin --password admin access-path list`

delete_ap(){
xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin target list |\
xargs -I {} sh -c  'xms-cli --user admin -p admin access-path delete {}; sleep 5'
}

### Create target
create_target(){
$cli target create -a $ap_id --host 1
$cli target create -a $ap_id --host 2
$cli target create -a $ap_id --host 3
}

delete_target(){
echo "delete target"
xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin target list |\
xargs -I {} sh -c  'xms-cli --user admin -p admin target delete {}; sleep 3'
}


### Create mapping-group
create_mp(){
$cli mapping-group create -a $ap -v ${vol_list[0]}  -c $client_id
}

add_mp_lun(){
$cli mapping-group add block-volume $iscsi_id ${vol_list[1]}
}

delete(){
    xms-cli  -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin mapping-group list |\
    xargs -I {} sh -c  'xms-cli --user admin -p admin mapping-group delete {}; sleep 5'
    sleep 60
}

## Remote find and mount the volume, plus IO
client_io(){
echo "Remote find and mount the volume, plus IO"
ssh root@$client "sh /root/much_iscsi.sh 1>&- 2>&- &"
ssh root@$client "fio /root/much_lun.block"
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

### stop io
client_stop_io(){
ssh root@$client "sh /root/stop_io.sh"
}


### Build  pool error

#xms-cli -f '{{range .}}{{println .id }}{{end}}' --user admin --password admin osd list -q "pool.name:hdd_pool" -q "host.name:node196"
#pool_osd=`xms-cli -f '{{range .}}{{println .id .name .host.name}}{{end}}' --user admin --password admin osd list -q "pool.name:hdd_pool"`
buid_pool_err(){
hdd_osd1=(`xms-cli -f '{{range .}}{{println  .name .host.name}}{{end}}' --user admin --password admin osd list -q "pool.name:hdd_pool"|grep node196|sed --expression='s/^osd.//g' --expression='s/node196//g'`)
echo ${199hdd_osd[@]}
hdd_osd2=(`xms-cli -f '{{range .}}{{println  .name .host.name}}{{end}}' --user admin --password admin osd list -q "pool.name:hdd_pool"|grep node197|sed --expression='s/^osd.//g' --expression='s/node197//g'`)

# node196
for i in ${hdd_osd1[@]}
do
    device=(`ssh root@10.252.3.196 "lsblk|grep -B 1 ceph-${i}|grep disk|awk '{print $1}'"`)
    echo $device
    disk_id=(`ssh root@10.252.3.196 "lsscsi |grep sdh"`)
    scsi_id=`echo ${disk_id[0]}|sed --expression='s/\[//g' --expression='s/\]//g'`
    echo $scsi_id
    ssh root@10.252.3.196 "echo "scsi remove-single-device ${scsi_id}" > /proc/scsi/scsi"
    echo "remove ${scsi_id} secceed!!!"
done
# node197
for i in ${hdd_osd2[@]}
do
    device=(`ssh root@10.252.3.197 "lsblk|grep -B 1 ceph-${i}|grep disk|awk '{print $1}'"`)
    echo $device
    disk_id=(`ssh root@10.252.3.197 "lsscsi |grep sdh"`)
    scsi_id=`echo ${disk_id[0]}|sed --expression='s/\[//g' --expression='s/\]//g'`
    echo $scsi_id
    ssh root@10.252.3.197 "echo "scsi remove-single-device ${scsi_id}" > /proc/scsi/scsi"
    echo "remove ${scsi_id} secceed!!!"
done
}

### check io stat
check_io(){
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


### check pool stat
check_stat(){
if ceph -s|grep HEALTH_ERR >> /dev/null
then
    echo "1"
else
    echo "0"
fi
}




### Create
create(){
create_vol
create_ap
create_client
create_target
create_mp
add_mp_lun
client_io
buid_pool_err
check_io
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
}

################ main ################
create
#delete
