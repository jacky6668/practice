#!/bin/bash
#AT 3.2.10 version, water level of osd is ambiguous.
#This script is used to calculate the real water level of osd for the occasion.

for i in {0..6}
do
    write_count=`ceph --admin-daemon /var/run/ceph/ceph-osd.$i.asok perf dump | grep mscache_nvcache_write_block_count | awk -F ':|,' '{ print $2 }'`
    #echo "write count of osd.$i is :${write_count}"
    total_count=`ceph --admin-daemon /var/run/ceph/ceph-osd.$i.asok perf dump | grep mscache_nvcache_total_block_count | awk -F ':|,' '{ print $2 }'`
    #echo "total count of osd.$i is :${total_count}"

    if [[ -z ${write_count} && -z ${total_count} ]];then
        echo "osd.$i is not in this server"
    else
        water_level=$[write_count*100/total_count]
        echo "water level of osd.$i is :${water_level}"
    fi
done
