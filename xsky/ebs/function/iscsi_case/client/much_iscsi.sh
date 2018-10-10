#!/bin/bash
ip="
10.252.2.195
10.252.2.196
10.252.2.197
"
for i in $ip
do
        echo "iscsi discovery $i"
	session=`iscsiadm -m discovery -p $i:3260 -t st`
	sleep 3
	res=`echo $session|tr " " "\n"|sort|uniq`
	port=`echo $session|tr " " "\n"|sort|uniq|grep "3260"|awk -F"," '{print $1}'`
	iqn=`echo $session|tr " " "\n"|sort|grep iqn`
        echo "mount iqn"
	for i in $iqn
	do
	    iscsiadm -m node -T $i -P $port --login
	done
done
sleep 5

echo "Retrieve the drive"

drive=`multipath -ll|grep "XSKY"|awk '{print $3}'`
bs=(4K 32K 64K 128K 512K 1024k 2048k 4096k 8192k 5k 7k 1020k 11k)
#rw=(write randwrite read  randread randrw)
rw=(write randwrite randrw)
dri_num=`multipath -ll|grep "XSKY"|wc -l`

## set work
echo "Set fio work"
echo "\
[global]
ioengine=libaio
direct=1
thread
group_reporting
norandommap=1
randrepeat=0
runtime=99999999
name=test
time_based
continue_on_error=none
norandommap
" > much_lun.block
sleep 2

w=1
for i in $drive
do
echo "
[work$w]
filename=/dev/$i
bs=4k
rw=write
numjobs=4
iodepth=32
" >> much_lun.block
let w=$w+1
done
sleep 2

## set bs
echo "Set bs"
for i in {1..${dri_num}}
do
    index=$(($RANDOM%${#bs[@]}))
    sed -i '0,/bs=4k/s//bs='${bs[$index]}'/' much_lun.block
done
sleep 2

## set rw
echo "Set rw"
for i in {1..${dri_num}}
do
   index=$(($RANDOM%${#rw[@]}))
   sed -i '0,/rw=write/s//rw='${rw[$index]}'/' much_lun.block
done
sleep 5
echo "Set succeed"

