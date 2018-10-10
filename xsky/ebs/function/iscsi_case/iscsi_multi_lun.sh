#!/bin/bash
# -------------------------------------------------------------------------------
# Filename:    iscsi_multi_lun.sh 
# Revision:    1.0
# Date:        2018/08/10
# Author:      yibo
# Email:       yibo@xsky.com
# Description: Build single iscsi ap with multi vols
# Notes:       This plugin uses the "" command
# -------------------------------------------------------------------------------
# Copyright:   2018 (c) yibo


cli="xms-cli --user admin --password admin"
pool_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin pool list`

### volume
create_vol() {
echo "Create volume...."
for i in {1..6} 
do
    $cli block-volume create -p $pool_id -s 100g vol_$i
    sleep 3
done
sleep 10
vol_list=(`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-volume list --limit -1`)
vol1=(`echo ${vol_list[0]} | tr [:space:] "," | sed 's/,$//g'`)
#vol2=(`echo ${vol_list[6]} | tr [:space:] "," | sed 's/,$//g'`)
vol_id1=(`echo ${vol_list[@]:1:11} | tr [:space:] "," | sed 's/,$//g'`)
#vol_id2=(`echo ${vol_list[@]:7:5} | tr [:space:] "," | sed 's/,$//g'`)
}

delete_vol() {
   xms-cli  -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-volume list |\
   xargs -I {} sh -c  'xms-cli --user admin -p admin block-volume delete {}; sleep 5'

}

### client-group
create_cli() {
#$cli client-group create --type iSCSI --codes "iqn.1994-05.com.redhat:e1621413ee,iqn.1994-05.com.redhat:83bbbfd01bd4" iscsi_client_136
#$cli client-group create --type iSCSI --codes "iqn.1994-05.com.redhat:e1621413ee" iscsi_client_136
$cli client-group create --type iSCSI --codes "iqn.1991-05.com.microsoft:win-f6mhhocu2qn" iscsi_client_145
#$cli client-group create --type iSCSI --codes "iqn.1994-05.com.redhat:83bbbfd01bd4" iscsi_client_138
cli_id=(`xms-cli -f '{{range .}}{{println .id }}{{end}}' --user admin --password admin client-group list`)
echo "iscsi client's id is ${cli_id}"
}

delete_cli() {
    xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin client-group list |\
    xargs -I {} sh -c  'xms-cli --user admin -p admin client-group delete {}; sleep 5'
    sleep 20
}

### access-path
create_ap() {
echo "Create 1 local access-path..."
for i in {1..1} 
do
    ${cli} access-path create --type iSCSI iscsi198
done
sleep 10
ap_id=(`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin access-path list`)
}

delete_ap() {
    xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin access-path list |\
    xargs -I {} sh -c  'xms-cli --user admin -p admin access-path delete {}; sleep 5'
    sleep 20
}

### target
create_t() {
echo "Create 3 target..."
host_id=(`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin host list`)
#host_id=(`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin host list -q "name=node198"`)
echo $ap_id
echo $host_id
$cli target create -a ${ap_id[0]} --host ${host_id[0]}
$cli target create -a ${ap_id[0]} --host ${host_id[1]}
$cli target create -a ${ap_id[0]} --host ${host_id[2]}
sleep 15
}

delete_t() {
    xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin target list |\
    xargs -I {} sh -c  'xms-cli --user admin -p admin target delete {}; sleep 5'
    sleep 20
}

### mapping-group
create_mp() {
echo "create mp..."
$cli mapping-group create -a ${ap_id[0]} -v ${vol1} -c ${cli_id[0]}
#$cli mapping-group create -a ${ap_id[0]} -v ${vol2} -c ${cli_id[1]}
sleep 15
mp_id=(`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin mapping-group list`)
$cli mapping-group add block-volume  ${mp_id[0]} ${vol_id1}
#$cli mapping-group add block-volume  ${mp_id[1]} ${vol_id2}
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
arg=${1}
case ${arg} in
    c)
        create
    ;;
    d)
        delete
    ;;
    *)
        echo "args are wrong"
        echo "c|d"
    ;;
esac
