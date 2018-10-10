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
$cli block-volume create -p $ssd_id -s 322122547200 -f 128 lun_v3_1
$cli block-volume create -p $ssd_id -s 322122547200 -f 128 lun_v3_2
}
vol_list=(`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-volume list --limit -1`)

delete_vol(){
for i in ${arr[@]}
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

### check pool stat
check_stat(){
if ceph -s|grep full >> /dev/null
then
    echo "1"
else
    echo "0"
fi
}

## Set the pool disk threshold
set_dt(){
    echo "set osd-full-ratio 0.95"
    $cli pool set --osd-full-ratio 0.95 $hybird_id
    $cli pool set --osd-full-ratio 0.95 $hdd_id
    sleep 60
    echo "set osd-full-ratio 0.85"
    $cli pool set --osd-full-ratio 0.85 $hybird_id
    $cli pool set --osd-full-ratio 0.85 $hdd_id
    sleep 60
done
}

### loop
loop_disk(){
for i in {1..10}
if [ check_stat -eq "1" ]
then
   set_dt
else
   echo "There is no pool full"
fi
do
done
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
loop_disk
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
