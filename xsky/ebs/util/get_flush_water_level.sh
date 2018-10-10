#!/bin/bash


for i in {0..11}
do
    ceph --admin-daemon /var/run/ceph/ceph-osd.${i}.asok perf dump | grep -A 3 mscache | grep level
done
