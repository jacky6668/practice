#!/bin/bash
cli="xms-cli --user admin --password admin"
pool_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin pool list`

## Create volume
#echo "Create 1024 volume...."
#for i in {1..1024} 
#do
#    $cli block-volume create -p $pool_id -s 10g vol_$i
#done
#sleep 180
vol_list=(`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-volume list --limit -1`)
#vol1=(`echo ${vol_list[0]} | tr [:space:] "," | sed 's/,$//g'`)
#vol2=(`echo ${vol_list[255]} | tr [:space:] "," | sed 's/,$//g'`)
#vol3=(`echo ${vol_list[510]} | tr [:space:] "," | sed 's/,$//g'`)
#vol4=(`echo ${vol_list[765]} | tr [:space:] "," | sed 's/,$//g'`)
#vol5=(`echo ${vol_list[1020]} | tr [:space:] "," | sed 's/,$//g'`)
#vol_id1=(`echo ${vol_list[@]:1:254} | tr [:space:] "," | sed 's/,$//g'`)
#vol_id2=(`echo ${vol_list[@]:256:254} | tr [:space:] "," | sed 's/,$//g'`)
#vol_id3=(`echo ${vol_list[@]:512:254} | tr [:space:] "," | sed 's/,$//g'`)
#vol_id4=(`echo ${vol_list[@]:768:254} | tr [:space:] "," | sed 's/,$//g'`)
#vol_id5=(`echo ${vol_list[@]:1023:254} | tr [:space:] "," | sed 's/,$//g'`)

vol_id1=(`echo ${vol_list[@]:1:100} | tr [:space:] "," | sed 's/,$//g'`)
vol_id2=(`echo ${vol_list[@]:101:100} | tr [:space:] "," | sed 's/,$//g'`)
vol_id3=(`echo ${vol_list[@]:201:100} | tr [:space:] "," | sed 's/,$//g'`)


echo $vol1
echo $vol2
echo $vol3
echo $vol4
echo $vol5
echo "##################"
echo $vol_id1
echo "######################"
echo $vol_id2
echo "#########################"
echo $vol_id3
echo "##############################"
echo $vol_id4
echo "####################################"
echo $vol_id5



#### Create access-path
#echo "Create 5 local access-path..."
#for i in {1..5} 
#do
#    ${cli} access-path create --type Local local_$i
#done
#sleep 10

#### Create target
#echo "Create 3 target..."

ap_id=(`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin access-path list`)
host_id=(`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin host list`)

#echo $ap_id
#echo $host_id
#$cli target create -a ${ap_id[0]} --host ${host_id[0]}
#$cli target create -a ${ap_id[1]} --host ${host_id[1]}
#$cli target create -a ${ap_id[2]} --host ${host_id[2]}
#$cli target create -a ${ap_id[3]} --host ${host_id[0]}
#$cli target create -a ${ap_id[4]} --host ${host_id[1]}
#sleep 120

### Create mapping-group
#echo "create mp..."
#$cli mapping-group create -a ${ap_id[0]} -v ${vol1}
#$cli mapping-group create -a ${ap_id[1]} -v ${vol2}
#$cli mapping-group create -a ${ap_id[2]} -v ${vol3}
#$cli mapping-group create -a ${ap_id[3]} -v ${vol4}
#$cli mapping-group create -a ${ap_id[4]} -v ${vol5}
#sleep 10

#mp_id=(`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin mapping-group list`)
#$cli mapping-group add block-volume  ${mp_id[0]} ${vol_id1}
#$cli mapping-group add block-volume  ${mp_id[1]} ${vol_id2}
#$cli mapping-group add block-volume  ${mp_id[2]} ${vol_id3}
#$cli mapping-group add block-volume  ${mp_id[3]} ${vol_id4}
#$cli mapping-group add block-volume  ${mp_id[4]} ${vol_id5}

#mp_id=`xms-cli -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin mapping-group list`
#$cli mapping-group add block-volume $mp_id ${vol_id1}

#vol_id6=`echo ${vol_list[@]:0:724}`
#
#for i in $vol_id6
#do
#    echo $i
#    $cli block-volume delete $i
#done


