#!/bin/bash

if [ -z ${1} ];then
echo "need water level!"
exit 0
fi #end of if

for i in {0..11}
do
    ceph tell osd.${i} injectargs "--mscache_flush_waterlevel ${1}"
    ceph daemon osd.${i} config show | grep mscache | grep level
done #end of do
