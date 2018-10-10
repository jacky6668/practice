#!/bin/bash
ip='
10.252.2.195
10.252.2.196
10.252.2.197
'
discovery_vol(){
for i in $ip
do
    session=`iscsiadm -m discovery -p $i -t st`
    sleep 1
    ip_port=`echo $session|awk -F , {'print $1'}`
    iqn=`echo $session|awk {'print $2'}`
    iscsiadm -m node -T $iqn -p $ip_port --login
done
}
device_name=`multipath -ll|grep XSKY|awk '{print $3}'`
### Randrw io
randrw_io()
{
    fio -filename=/dev/$device_name  -thread -rw=randrw -bs=4k -ioengine=libaio -group_reporting -name=mytest -randrepeat=0 -time_based -runtime=300 -direct=1  -iodepth=64 -numjobs=4 &
}

randwrite_io()
{
    fio -filename=/dev/$device_name  -thread -rw=randwrite -bs=4k -ioengine=libaio -group_reporting -name=mytest -randrepeat=0 -time_based -direct=1  -iodepth=64 -numjobs=4 &
}
### Read io
read_io()
{
fio -filename=/dev/$device_name  -thread -rw=randread -bs=4k -ioengine=libaio -group_reporting -name=mytest -randrepeat=0 -time_based -runtime=300 -direct=1  -iodepth=64 -numjobs=4
sleep 10
echo "The second reading"
fio -filename=/dev/$device_name  -thread -rw=randread -bs=4k -ioengine=libaio -group_reporting -name=mytest -randrepeat=0 -time_based -runtime=300 -direct=1  -iodepth=64 -numjobs=4
sleep 10
echo "The second reading"
fio -filename=/dev/$device_name  -thread -rw=randread -bs=4k -ioengine=libaio -group_reporting -name=mytest -randrepeat=0 -time_based -runtime=300 -direct=1  -iodepth=64 -numjobs=4
}

to_io(){
discovery_vol
randwrite_io
}
to_read(){
read_io
}

to_randrw(){
discovery_vol
randrw_io
}

# ===Main===
#to_io
#to_read
to_randrw
