#!/bin/bash

create_clone() {
pID=`xms-cli  -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin pool list`
sID=`xms-cli  -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-snapshot list`
for i in {0..10}
do
	xms-cli --user admin --password admin block-volume clone --pool $pID --block-snapshot $sID  'fdl'$i
	sleep 10
done
}


delete_clone() {
xms-cli --user admin -p admin block-volume list|awk -F " " '{print $2"\t"$21}'|grep 'false'|awk -F " " '{print $1}'|xargs -I {} sh -c 'xms-cli --user admin -p admin block-volume delete {}'

#sleep 10
}


for i in {0..10}
do
       create_clone
       sleep 10
       delete_clone
       sleep 10
done
