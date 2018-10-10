#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    much_ap_single_lun 
# Revision:    1.0
# Date:        2018/08/21
# Author:      yangyang
# Email:       yangyang@xsky.com
# Description: Build 3 local ap with multi vols
# Notes:       This plugin uses the "" command
# -------------------------------------------------------------------------------
# Copyright:   2018 (c) yangyang

### Variable Comments
cli="xms-cli --user admin --password admin"
pool_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin pool list`
iqn="10.252.2.137"
client='10.252.3.137'
node3='10.252.3.200'
num=`seq 1 50 |sort -n`

### Create vol
create_vol()
{
echo "Create volume lun_v3"
for i in $num
do
    $cli block-volume create -p $pool_id -s 107374182400 -f 128 lun_v3_$i
done
sleep 2
}
vol_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-volume list --limit -1`

delete_vol(){
   echo "delete vol"
   xms-cli  -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-volume list |\
   xargs -I {} sh -c  'xms-cli --user admin -p admin block-volume delete {}; sleep 3'
}

### Create client-group
create_client(){
echo "create client-group"
$cli client-group create --type iSCSI --codes "$iqn" iscsi_client
sleep 3
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
for i in $num
do
    ${cli} access-path create --type iSCSI iscsi_path_$i
sleep 3
done
}
ap_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin access-path list`

delete_ap(){
echo "delete access-path"
xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin access-path list |\
xargs -I {} sh -c  'xms-cli --user admin -p admin access-path delete {}; sleep 5'
sleep 10
}

create_target(){
echo "create target"
ap_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin access-path list`
for i in $ap_id
do
$cli target create -a $i --host 1
$cli target create -a $i --host 2
$cli target create -a $i --host 3
done
sleep 6
}

delete_target(){
echo "delete target"
xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin target list |\
xargs -I {} sh -c  'xms-cli --user admin -p admin target delete {}; sleep 5'
}

### Create mapping-group
create_mp(){
echo "create mp..."
ap_id=(`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin access-path list`)
vol_id=(`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-volume list --limit -1`)
client_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin client-group list`
for i in {0..50}
do
    vol=`echo ${vol_id[${i}]}`
    ap1=`echo ${ap_id[${i}]}` 
    $cli mapping-group create -a $ap1 -v $vol -c $client_id
done
sleep 10
echo "create success"
}

mp_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin mapping-group list`

delete_mp(){
echo "delete mapping-group"
$cli mapping-group delete $mp_id
sleep 10
}


### Add exception
stop_xdc(){
ssh root@$node3 "sh mixed_case.sh xdc 1>&- 2>&- &"
}

nostop_xdc(){
ssh root@$node3 "ps -ef|grep 'mixed_case'|grep -v grep|cut -c 9-15|xargs kill -9  1>&- 2>&- &"
sleep 10
}

### Volume increase
lun_expansion(){
echo "Volume increase.."
for i in $vol_id
do
$cli block-volume set -s 150g $vol_id
sleep 2
done

for i in {1..30}
do
    sleep 1
    vol_status=`xms-cli -f '{{range .}}{{println .status}}{{end}}' --user admin --password admin block-volume list`
    if [[  $vol_status = "active" ]]
    then
        echo "volume status is:$vol_status"
        break
    else
        continue
    fi
done
echo "Volume increase is ok!!"
sleep 10
}

## Pool set the bypass
pool_bypass(){
echo "pool set the bypass"
$cli pool set --io-bypass-enabled --io-bypass-threshold 128 $pool_id
}
    
## Set volume performance-priority
vol_pp(){
echo "Set volume performance-priority... "
sleep 2
for i in $vol_id
do
$cli block-volume set --performance-priority 1 $i
done

for i in {1..30}
do
    sleep 1
    vol_status=`xms-cli -f '{{range .}}{{println .status}}{{end}}' --user admin --password admin block-volume list -q "name:iscsi_v3_1"`
    if [[  $vol_status = "active" ]]
    then
        echo "volume status is:$vol_status"
        break
    else
        continue
    fi
done
echo "Set volume performance-priority succeed!!!"
sleep 3
}

## Pool set reweight
pool_reweight(){
echo "pool set reweight.."
$cli pool reweight $pool_id
for i in {1..15}
do
    sleep 1
    pool_status=`xms-cli -f '{{range .}}{{println .status}}{{end}}' --user admin --password admin pool list -q "name:Hybird_pool"`
    if [[ $pool_status = "active"  ]]
    then
        echo "pool status is:$pool_status"
        break
    else
        continue
    fi
done
sleep 10
echo "Pool set reweight succeed!!!"
}
### Set lun qos
lun_qos(){
echo "set lun qos"
for i in $vol_id
do
$cli block-volume set --qos-enabled --max-total-iops 112 --max-total-bw 10485760 --burst-total-bw 15728640 --burst-total-iops 120 -description 'max_iops:112,max_bw:10M,burst_bw:15M,burst_iops:120' $i
#$cli block-volume set --qos-enabled --max-total-iops 112 --burst-total-iops 120 -description 'The maximum IOPS was 112 and the burst IOPS was 120' $i
#$cli block-volume set --qos-enabled --max-total-bw 10485760 --burst-total-bw 15728640 -description 'Maximum bandwidth of 10M, sudden bandwidth of 15M' $i
done
}

### Set pool scrub
set_scrub(){
echo "set pool scrub"
$cli pool set --scrub-begin 01:00 --scrub-end 02:00 $pool_id
sleep 8
}


### Set pool recovery qos
pool_qos(){
##set static pool recovery-qos
#echo "set recover qos high"
#$cli pool set --mode 1 --recovery-rate-type=high $pool_id
echo "set recover qos middle"
$cli pool set --mode 1 --recovery-rate-type=middle $pool_id
#echo "set recover qos low"
#$cli pool set --mode 1 --recovery-rate-type=low $pool_id

## set dynamic pool recover-qos
#$cli set --mode 1 --bandwidth 10485760 $pool_id
#$cli set --mode 1 ----bandwidth-max 20971520 $pool_id
#$cli set --mode 1 --client-threshold 31273230 $pool_id
}

### Set the hard disk Capacity threshold
disk_threshold_85(){
echo "set disk threshold 85"
$cli pool set --osd-full-ratio 0.85 $pool_id
sleep 8
}
disk_threshold_90(){
echo "set disk threshold 90"
$cli pool set --osd-full-ratio 0.9 $pool_id
sleep 8
}


### Close pool bypass
pool_close_bypass(){
echo "Close pool-bypass"
$cli pool set --io-bypass-enabled=false $pool_id
}

### Huddle up capacity
lun_reduction(){
echo "set block-volume set 300->180"
sleep 10
$cli block-volume set -s 300g $vol_id
for i in {1..30}
do
    sleep 1
    if [[  $vol_status = "active" ]]
    then
        echo "volume status is:$vol_status"
        break
    else
        continue
    fi
done
$cli block-volume set -s 180g $vol_id
for i in {1..30}
do
    sleep 1
    if [[  $vol_status = "active" ]]
    then
        echo "volume status is:$vol_status"
        break
    else
        continue
    fi
done
echo "Volume increase is ok!!"
sleep 10
}
### close pool scrub
unset_scrub(){
echo "close pool scrub"
$cli pool set --scrub-begin 00:00 --scrub-end 00:00 $pool_id
sleep 8
}

### close volume performance-priority
lun_close_pp(){
echo "Set close volume performance-priority... "
for i in $vol_id
do
    $cli block-volume set --performance-priority 0 $i
    sleep 2
done
for i in {1..30}
do
    sleep 1
    vol_status=`xms-cli -f '{{range .}}{{println .status}}{{end}}' --user admin --password admin block-volume list -q "name:iscsi_v3_1"`
    if [[  $vol_status = "active" ]]
    then
        echo "volume status is:$vol_status"
        break
    else
        continue
    fi
done
sleep 3
echo "Set close volume performance-priority succeed!!!"
}

### pool set reweight
pool_reweight(){
echo "pool set reweight"
$cli pool reweight $pool_id
for i in {1..15}
do
    sleep 1
    pool_status=`xms-cli -f '{{range .}}{{println .status}}{{end}}' --user admin --password admin pool list -q "name:Hybird_pool"`
    if [[ $pool_status = "active"  ]]
    then
        echo "pool status is:$pool_status"
        break
    else
        continue
    fi
done
sleep 3
echo "Pool set reweight succeed!!!"
}

osd_id=`xms-cli -f '{{range .}}{{println .id }}{{end}}' --user admin --password admin osd list`
### Pool remove a osd
pool_remove_osd(){
echo "pool remove a osd"
    $cli pool remove osd $pool_id $osd_id
    echo "sleep 300s"
    sleep 300
    $cli pool add osd $pool_id $osd_id
}


### loop case
loop_case(){
for i in {1..10}
do
echo "Loop count:${i}"
	lun_expansion
	pool_bypass
	vol_pp
	pool_reweight
	lun_qos
	set_scrub
	pool_qos
	pool_remove_osd
	disk_threshold_85
	disk_threshold_90
	pool_close_bypass
	lun_reduction
	unset_scrub
	lun_close_pp
echo "Loop count:${i} END"
done
}

### Create
create(){
create_vol
sleep 60
create_client
sleep 10
create_ap
sleep 30
create_target
sleep 300
create_mp
sleep 300
loop_case
}

### Delete
delete(){
delete_mp
delete_target
delete_ap
delete_client
delete_vol
}

###Main###
create
#delete
#loop_case
