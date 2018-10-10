#!/bin/bash

create_volume() {
    pid=`xms-cli  -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin pool list`
    for i in {1..50}
    do
        xms-cli --user admin -p admin block-volme create --pool ${pid} --size 102400000000 v$i
        sleep 5
    done
}

delete_volume() {
   xms-cli  -f '{{range .}}{{println .id}}{{end}}' --user admin --password admin block-volume list |\
   xargs -I {} sh -c  'xms-cli --user admin -p admin block-volume delete {}; sleep 5'

}


for i in {0..1}
do
    create_volume
    sleep 10
    delete_volume
    sleep 10
done

