#!/bin/bash
cli="xms-cli --user admin --password admin"
num=`seq 0 1023`
pool_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin pool list -q "name:HybirdPool"`
echo $pool_id

#echo "Create 1024 volume...."
#for i in $num
#do
#    sleep 1
#    echo $i
#    $cli block-volume create -p $pool_id -s 100g lun_v3_$i
#done
#echo "Create 1024 volume succeed!!"
#
### Create access-path
#echo "Create 1024 access-path..."
#for i in $num
#do
#    ${cli} access-path create --type Local local_path_$i
#done
#sleep 5
#scsi_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin access-path list`
#sleep 15
#for i in $scsi_id
#do
#    $cli target create -a $i --host 1
#done
#sleep 360
#for i in $num
#do
#    echo "Create mapping-group $i"
#    path_id=`xms-cli -f '{{range .}}{{println .id .name}}{{end}}' --user admin --password admin access-path list|grep "local_path_$i$"|awk '{print $1}'`
#    vol_id=`xms-cli -f '{{range .}}{{println .id .name}}{{end}}' --user admin --password admin block-volume list|grep "lun_v3_$i$"|awk '{print $1}'`
#    $cli mapping-group create -a $path_id -v $vol_id
#done

map_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin mapping-group list`
for i in $map_id
do
    $cli mapping-group delete $i
    sleep 2
done
