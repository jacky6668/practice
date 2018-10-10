#!/bin/bash

echo -e "\033[35m start performence test\033[0m"
sec=20 #85100s
count=4255
date=`date +%Y%m%d%H%M`
resdir=/home/perform_results
here=/home/perform_results/res_${date}
path=/home/perform_tmp
bak=/home/perform_tmp/backup
host="
test41
test42
test43
"

# create results floder at this server
if [ -d ${resdir} ]
then
    echo -e "\033[31m ${resdir} is already existed\033[0m"
else
    mkdir ${resdir}
    echo -e "\033[32m ${resdir} has been created\033[0m"
fi

# create daily result floder at this server
if [ -d ${here} ]
then
    echo -e "\033[31m ${here} is already existed\033[0m"
else
    mkdir ${here}
    echo -e "\033[32m ${here} has been created\033[0m"
fi

# ssh to server nodes and create nmon file
echo -e "\033[35m create nmon file at server nodes\033[0m"
for ip in ${host}
do
    ssh root@${ip} "if [ -d ${path} ]; then cd ${path};rm -rf ${bak}/*.*;nmon -f -s ${sec} -c ${count}; \
                    else mkdir ${path};cd ${path};mkdir ${bak};nmon -f -s ${sec} -c ${count}; fi"
done

# start IO!
echo -e "\033[35m FIO at test server\033[0m"
#for rw in write read randwrite randread
for rw in randwrite randread
do
    sleep 30
    for bs in 4k 8k 64k 512k 4M 8M
    do
        sleep 20
        for iodepth in 1 64 128
        do
            sleep 20
            for nj in 1 4 8
            do
                for ip in ${host}
                do
	            ssh root@${ip} "echo 3 >/proc/sys/vm/drop_caches"
                    sleep 5
                    ssh root@${ip} "echo "====rw=${rw}---bs=${bs}---iodepth=${iodepth}---numjob=${nj}===:`date`" >> ${path}/fio_${ip}.log"
	            ssh root@${ip} "fio -thread -ioengine=libaio -group_reporting -name=mytest -randrepeat=0 -time_based -runtime=300 -direct=1 -filename=/dev/sdh:/dev/sdi -rw=${rw} -bs=${bs} -numjob=${nj} --iodepth=${iodepth} >> ${path}/fio_${ip}.log &"
                done # end of ip
                sleep 300 
            done # end of nj
	done # end of iodepth
    done # end of rw
done #end of bs

for rw in randrw 
do
    sleep 30
    for bs in 4k 8k 64k 512k 4M 8M
    do
        sleep 20
        for iodepth in 1 64 128
        do
            sleep 20
            for nj in 1 4 8
            do
                for ip in ${host}
                do
	            ssh root@${ip} "echo 3 >/proc/sys/vm/drop_caches"
                    sleep 5
                    ssh root@${ip} "echo "====rw=${rw}---bs=${bs}---iodepth=${iodepth}---numjob=${nj}===:`date`" >> ${path}/fio_${ip}.log"
	            ssh root@${ip} "fio -thread -ioengine=libaio -group_reporting -name=mytest -randrepeat=0 -time_based -runtime=300 -direct=1 -filename=/dev/sdh:/dev/sdi -rw=${rw} -rwmixread=70 -bs=${bs} -numjob=${nj} --iodepth=${iodepth} >> ${path}/fio_${ip}.log &"
                done # end of ip
                sleep 300 
            done # end of nj
	done # end of iodepth
    done # end of rw
done #end of bs



# wait nmon at server nodes
#echo -e "\033[35m waiting server nodes\033[0m"
#sleep 10

# get result files from server nodes
echo -e "\033[35m get results file frome server nodes\033[0m"
for ip in ${host}
do
   scp root@${ip}:${path}/* ${here}
   ssh root@${ip} "mv ${path}/*.* ${bak}/"
done

echo -e "\033[35m Success!\033[0m"

# fio --output-format=json --output=xx.json ssd-test.fio
