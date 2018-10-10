#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    16_volume_andpool__are_deeply_coupled
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
number=`seq 1 4 |sort -n`   ###Cycle number(create volume/access-path/mapping-group)

rand_num_big(){
    echo $(($RANDOM%146+155))
}
rand_num_small(){
    echo $(($RANDOM%51+100))
}

### Create vol
create_vol(){
$cli block-volume create -p $pool_id -s 100g -f 128 lun_v3
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

create_target(){
echo "create target"
$cli target create -a $ap_id --host 1
$cli target create -a $ap_id --host 2
$cli target create -a $ap_id --host 3
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
$cli mapping-group create -a $ap_id -v $vol_id -c $client_id
sleep 10
echo "create success"
}
mp_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin mapping-group list`

delete_mp(){
echo "delete mapping-group"
$cli mapping-group delete $mp_id
sleep 10
}

### Volume increase
lun_expansion(){
echo "Volume increase.."
for i in $vol_id
do
$cli block-volume set -s `rand_num_big`g $vol_id
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
echo "Volume increase is ok!!"
sleep 3
}

## Pool set the bypass
pool_bypass(){
$cli pool set --io-bypass-enabled --io-bypass-threshold $(echo $(($RANDOM%496+16))) $pool_id
sleep 15
}
    
## Set volume performance-priority
lun_set_pp(){
echo "Set volume  $1 performance-priority... "
$cli block-volume set --performance-priority 1 $1

for i in {1..30}
do
    sleep 2
    vol_status=`xms-cli -f '{{range .}}{{println .status}}{{end}}' --user admin --password admin block-volume list -q "id:$1"`
    if [[  $vol_status = "active" ]]
    then
        echo "volume status is:$vol_status"
        break
    else
        continue
    fi
done
echo "Set volume performance-priority succeed!!!"
sleep 10 
}

## Pool set reweight
pool_reweight(){
echo "pool set reweight.."
$cli pool reweight $pool_id
for i in {1..300}
do
    sleep 2
    pool_status=`xms-cli -f '{{range .}}{{println .status}}{{end}}' --user admin --password admin pool list -q "id:$pool_id"`
    if [[ $pool_status = "active"  ]]
    then
        echo "pool status is:$pool_status"
        break
    else
        continue
    fi
done
echo "Pool set reweight succeed!!!"
sleep 10
}

### Set lun qos
lun_qos(){
#$cli block-volume set --qos-enabled --max-total-iops 112 --burst-total-iops 120 -description 'The maximum IOPS was 112 and the burst IOPS was 120' $i
#$cli block-volume set --qos-enabled --max-total-bw 10485760 --burst-total-bw 15728640 -description 'Maximum bandwidth of 10M, sudden bandwidth of 15M' $i
max_iops=$(echo $(($RANDOM%280+20)))
burst_iops=$(expr $max_iops + 10)
bw=$(echo $(($RANDOM%90+60)))
max_bw=$(expr $bw \* 1024 \* 1024)
burst_bw=$(expr $(expr $bw + 10) \* 1024 \* 1024)
descr="max_iops:$max_iops;burst_iops:$burst_iops;bw:$bw;max_bw:$max_bw;burst_bw:$burst_bw;"
$cli block-volume set --qos-enabled --max-total-iops $max_iops --max-total-bw $max_bw --burst-total-bw $burst_bw --burst-total-iops $burst_iops --description $(echo $descr)  $1
sleep 10
}

### close lun qos
close_lun_qos(){
$cli block-volume set --qos-enabled=false $1
} 

### Set pool scrub
set_pool_scrub(){
pool_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin pool list`
for i in $pool_id
do
    $cli pool set set --scrub-begin 23:00 --scrub-end 00:00 $i
done
}

### Set pool recovery qos
pool_qos(){
pool_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin pool list`
for i in $pool_id
do
    rand_level=(high middle low)
    index=$(($RANDOM%${#rand_level[@]}))
    ##set static pool recovery-qos
    #echo "set recover qos high"
    #$cli pool set --mode 1 --recovery-rate-type=high $pool_id
    echo "set recover qos"
    $cli pool set --mode 1 --recovery-rate-type=${rand_level[$index]} $i
    #echo "set recover qos low"
    #$cli pool set --mode 1 --recovery-rate-type=low $pool_id
    
    ## set dynamic pool recover-qos
    #$cli set --mode 1 --bandwidth 10485760 $pool_id
    #$cli set --mode 1 ----bandwidth-max 20971520 $pool_id
    #$cli set --mode 1 --client-threshold 31273230 $pool_id
done
}

### close pool qos
close_pool_qos(){
pool_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin pool list`
for i in $pool_id
do
    $cli pool set --mode 0 $i
done
}

### Set the hard disk Capacity threshold
disk_threshold(){
echo "set disk threshold"
$cli set --osd-full-ratio $(echo 0.$(seq 8 9|shuf -n1)$(seq 1 5|shuf -n1)) $pool_id
}

### Close pool bypass
pool_close_bypass(){
echo "Close pool-bypass"
$cli set --io-bypass-enabled=false $pool_id
}

### Huddle up capacity
lun_reduction(){
echo "set block-volume set size:100~150"
sleep 10
$cli block-volume set -s ${rand_num_small}g $vol_id
for i in {1..30}
do
    sleep 1
    vol_status=`xms-cli -f '{{range .}}{{println .status}}{{end}}' --user admin --password admin block-volume list -q "id:$1"`
    if [[  $vol_status = "active" ]]
    then
        echo "volume status is:$vol_status"
        break
    else
        continue
    fi
done
#$cli block-volume set -s 180g $vol_id
#for i in {1..30}
#do
#    sleep 1
#    if [[  $vol_status = "active" ]]
#    then
#        echo "volume status is:$vol_status"
#        break
#    else
#        continue
#    fi
#done
echo "Volume increase is ok!!"
sleep 10
}

### close volume performance-priority
lun_close_pp(){
echo "Set close volume performance-priority... "
$cli block-volume set --performance-priority 0 $1

for i in {1..30}
do
    sleep 1
    vol_status=`xms-cli -f '{{range .}}{{println .status}}{{end}}' --user admin --password admin block-volume list -q "id:$1"`
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

### Pool remove a osd
pool_remove_osd(){
    osd_id=`xms-cli -f '{{range .}}{{println .id }}{{end}}' --user admin --password admin osd list|shuf -n1`
    $cli remove osd $pool_id $osd_id
    echo "sleep 300s"
    sleep 300
    $cli add osd $pool_id $osd_id
}

## rbd du pool/image
rbd_du(){
for i in $(ceph osd pool ls)
do
    echo -e  "\033[33m Show  volumes info in the pool:\033[0m  \033[31m $i \033[0m"
    for s in $(rbd ls $i)
    do
     rbd du $i/$s
    done
done
}

## rbd ls pool
rbd_ls_pool(){
for i in $(ceph osd pool ls)
do
    echo -e  "\033[33m Show the volumes list in the pool:\033[0m  \033[31m $i \033[0m"
    rbd ls $i
done
}

### rbd --loog
rbd_ls_long(){
for i in $(ceph osd pool ls)
do
    echo -e  "\033[33m rbd ls --long pool_uuid::\033[0m  \033[31m $i \033[0m"
    rbd ls --long $i
done
}

ssh root@$client "sh /root/stop_io.sh 1>&- 2>&- &"

### loop case
loop(){
for num in {1..1000000}
do
    for id in $vol_id
    do
        pool_bypass
        lun_set_pp $id
        rbd_du
        pool_reweight
        lun_qos $id
        set_pool_scrub
        rbd_ls_pool
        pool_qos
        disk_threshold
        lun_close_pp $id
        rbd_ls_long
        pool_close_bypass
        close_lun_qos $id
        close_pool_qos
        pool_reweight
    done #end of id
done #end of num
}

### Create
create(){
create_vol
create_client
create_ap
create_target
create_mp
}

### Delete
delete(){
client_stop_io
delete_mp
delete_target
delete_ap
delete_client
delete_vol
}

###Main###
arg=${1}
case ${arg} in
    c)
        create
    ;;
    d)
        delete
    ;;
    l)
        loop
    ;;
    *)
        echo "args are wrong"
        echo "c|d|l"
    ;;
esac
