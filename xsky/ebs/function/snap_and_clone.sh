#!/bin/bash

create_volume() {
    pid=`xms-cli  -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin pool list`
    for i in {1..300}
    do
        xms-cli --user admin -p admin block-volume create --pool ${pid} --size 102400000000 v$i
        sleep 10 
    done
}

create_snap() {
xms-cli  -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-volume list |\
xargs -I {} sh -c "xms-cli --user admin -p admin block-snapshot create --block-volume {} sn{}; sleep 10"
}

create_clone() {
pID=`xms-cli  -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin pool list`
xms-cli  -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-snapshot list |\
#xargs -I {} sh -c "xms-cli --user admin --password admin block-volume clone --flattened --pool $pID --block-snapshot {}  clone{}; sleep 10"
xargs -I {} sh -c "xms-cli --user admin --password admin block-volume clone --pool $pID --block-snapshot {}  clone{}; sleep 10"
}

delete_snap() {
        xms-cli  -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-snapshot list |\
        xargs -I {} sh -c "xms-cli --user admin -p admin block-snapshot delete {}; sleep 10"
}

delete_volume() {
   xms-cli  -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-volume list |\
   xargs -I {} sh -c  "xms-cli --user admin -p admin block-volume delete {}; sleep 10"

}

for i in {0..0}
do
    create_volume
    sleep 10
    create_snap
    sleep 10
    create_clone
    sleep 10
    #delete_snap
    #sleep 10
    #delete_volume
    #sleep 10
done
