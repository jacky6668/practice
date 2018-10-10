#!/bin/bash

create_snap() {
volid=`xms-cli  -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-volume list`
for i in {1..50}
do
        xms-cli --user admin -p admin block-snapshot create --block-volume ${volid} sn$i
        sleep 5
done
}

delete_snap() {
        xms-cli  -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-snapshot list |\
        xargs -I {} sh -c 'xms-cli --user admin -p admin block-snapshot delete {}; sleep 5'
}

for i in {0..1}
do
       create_snap
       sleep 10
       delete_snap
       sleep 10
done
