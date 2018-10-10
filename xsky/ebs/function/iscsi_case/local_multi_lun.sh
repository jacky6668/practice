#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    local_multi_lun.sh
# Revision:    1.0
# Date:        2018/08/10
# Author:      yibo
# Email:       yibo@xsky.com
# Description: Build 3 local ap with multi vols
# Notes:       This plugin uses the "" command
# -------------------------------------------------------------------------------
# Copyright:   2018 (c) yibo


cli="xms-cli --user admin --password admin"
pool_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin pool list`

### volume
create_vol() {
echo "Create 120 volume...."
for i in {1..120} 
do
    $cli block-volume create -p $pool_id -s 6g vol_$i
    sleep 3
done
sleep 10
vol_list=(`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-volume list --limit -1`)
vol1=(`echo ${vol_list[0]} | tr [:space:] "," | sed 's/,$//g'`)
vol2=(`echo ${vol_list[40]} | tr [:space:] "," | sed 's/,$//g'`)
vol3=(`echo ${vol_list[80]} | tr [:space:] "," | sed 's/,$//g'`)
vol_id1=(`echo ${vol_list[@]:1:39} | tr [:space:] "," | sed 's/,$//g'`)
vol_id2=(`echo ${vol_list[@]:41:39} | tr [:space:] "," | sed 's/,$//g'`)
vol_id3=(`echo ${vol_list[@]:81:39} | tr [:space:] "," | sed 's/,$//g'`)
}

delete_vol() {
   xms-cli  -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-volume list |\
   xargs -I {} sh -c  'xms-cli --user admin -p admin block-volume delete {}; sleep 5'

}

#### access-path
create_ap() {
echo "Create 3 local access-path..."
for i in {1..3} 
do
    ${cli} access-path create --type Local local_$i
done
sleep 10
}

delete_ap() {
    xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin access-path list |\
    xargs -I {} sh -c  'xms-cli --user admin -p admin access-path delete {}; sleep 5'
    sleep 20
}

#### target
create_t() {
echo "Create 3 target..."
ap_id=(`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin access-path list`)
host_id=(`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin host list`)
echo $ap_id
echo $host_id
$cli target create -a ${ap_id[0]} --host ${host_id[0]}
$cli target create -a ${ap_id[1]} --host ${host_id[1]}
$cli target create -a ${ap_id[2]} --host ${host_id[2]}
sleep 5
}

delete_t() {
    xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin target list |\
    xargs -I {} sh -c  'xms-cli --user admin -p admin target delete {}; sleep 5'
    sleep 20
}

#### Create mapping-group
create_mp() {
echo "create mp..."
$cli mapping-group create -a ${ap_id[0]} -v ${vol1}
$cli mapping-group create -a ${ap_id[1]} -v ${vol2}
$cli mapping-group create -a ${ap_id[2]} -v ${vol3}
sleep 5s
mp_id=(`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin mapping-group list`)
$cli mapping-group add block-volume  ${mp_id[0]} ${vol_id1}
$cli mapping-group add block-volume  ${mp_id[1]} ${vol_id2}
$cli mapping-group add block-volume  ${mp_id[2]} ${vol_id3}
}

delete_mp() {
    xms-cli  -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin mapping-group list |\
    xargs -I {} sh -c  'xms-cli --user admin -p admin mapping-group delete {}; sleep 5'
    sleep 60
}

### create cluster
create() {
create_vol
create_cli
create_ap
create_t
create_mp
}

### delete cluster
delete() {
delete_mp
delete_t
delete_ap
delete_cli
delete_vol
}


#### main
create
#delete
