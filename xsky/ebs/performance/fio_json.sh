#!/bin/bash

date=`date +%Y%m%d%H%M`
resdir=/home/perform_results # final result dir
here=/home/perform_results/res_${date} # the dir of servers' files in one test
path=/home/perform_tmp # the dir of this server's files in one test
bak=/home/perform_tmp/backup # bak dir
#hostname or ip of servers in this testing
host="
"
create_dir()
{
    echo -e "\033[35m start performence test\033[0m"
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
}

start_nmon()
{
    # ssh to server nodes and create nmon file
    echo -e "\033[35m create nmon file at server nodes\033[0m"
    for ip in ${host}
    do
        #ssh root@${ip} "if [ -d ${path} ]; then cd ${path};rm -rf ${bak}/*.*;nmon -f -s ${sec} -c ${count}; \
            #else mkdir ${path};cd ${path};mkdir ${bak};nmon -f -s ${sec} -c ${count}; fi"
        ssh root@${ip} "if [ -d ${path} ]; then cd ${path};rm -rf ${bak}/*.*; \
        else mkdir ${path};cd ${path};mkdir ${bak}; fi"
    done
}

seq()
{
    #for rw in write read randwrite randread
    for rw in write read
    do
        sleep 5
        #for bs in 4k 8k 64k 512k 4M 8M
        for bs in 64k 512k
        do
            for iodepth in 1 64 128 256
            do
                for nj in 1 4 8 16
                do
                    for ip in ${host}
                    do
                        ssh root@${ip} "fio -thread -ioengine=libaio -group_reporting -name=mytest -randrepeat=0 -time_based -runtime=300 -direct=1 --output-format=json --output=${path}/${rw}-${bs}-${iodepth}-${nj}-${ip}.json -filename=/dev/sdi:/dev/sdj -rw=${rw} -bs=${bs} -numjob=${nj} --iodepth=${iodepth} " &
                    done # end of ip
                    sleep 305
                    for ip in ${host}
                    do
                        ssh root@${ip} "echo 3 >/proc/sys/vm/drop_caches" &
                    done # end of ip
                    sleep 5
                done # end of nj
            done # end of iodepth
        done # end of rw
    done #end of bs
}

rand()
{
    for rw in randwrite randread
    do
        sleep 5
        #for bs in 4k 8k 64k 512k 4M 8M
        for bs in 4k 8k
        do
            for iodepth in 1 64 128 256
            do
                for nj in 1 4 8 16
                do
                    for ip in ${host}
                    do
                        ssh root@${ip} "fio -thread -ioengine=libaio -group_reporting -name=mytest -randrepeat=0 -time_based -runtime=300 -direct=1 --output-format=json --output=${path}/${rw}-${bs}-${iodepth}-${nj}-${ip}.json -filename=/dev/sdi:/dev/sdj -rw=${rw} -bs=${bs} -numjob=${nj} --iodepth=${iodepth} " &
                    done # end of ip
                    sleep 305
                    for ip in ${host}
                    do
                        ssh root@${ip} "echo 3 >/proc/sys/vm/drop_caches" &
                    done # end of ip
                    sleep 5
                done # end of nj
            done # end of iodepth
        done # end of rw
    done #end of bs
}

rw()
{
    for rw in randrw
    do
        sleep 5
        #for bs in 4k 8k 64k 512k 4M 8M
        for bs in 4k 8k
        do
            for iodepth in 1 64 128 256
            do
                for nj in 1 4 8 16
                do
                    for ip in ${host}
                    do
                        ssh root@${ip} "fio -thread -ioengine=libaio -group_reporting -name=mytest -randrepeat=0 -time_based -runtime=300 -direct=1 -rwmixread=70 --output-format=json --output=${path}/${rw}-${bs}-${iodepth}-${nj}-${ip}.json -filename=/dev/sdi:/dev/sdj -rw=${rw} -bs=${bs} -numjob=${nj} --iodepth=${iodepth} " &
                    done # end of ip
                    sleep 305
                    for ip in ${host}
                    do
                        ssh root@${ip} "echo 3 >/proc/sys/vm/drop_caches" &
                    done # end of ip
                    sleep 5
                done # end of nj
            done # end of iodepth
        done # end of rw
    done #end of bs
}

lat()
{
    for rw in write read randwrite randread
    do
        sleep 5
        #for bs in 4k 8k 64k 512k 4M 8M
        for bs in 4k 8k 64k 512k
        do
            for iodepth in 1
            do
                for nj in 1
                do
                    for ip in ${host}
                    do
                        ssh root@${ip} "fio -thread -ioengine=libaio -group_reporting -name=mytest -randrepeat=0 -time_based -runtime=300 -direct=1 --output-format=json --output=${path}/${rw}-${bs}-${iodepth}-${nj}-${ip}.json -filename=/dev/sdi:/dev/sdj -rw=${rw} -bs=${bs} -numjob=${nj} --iodepth=${iodepth} " &
                    done # end of ip
                    sleep 305
                    for ip in ${host}
                    do
                        ssh root@${ip} "echo 3 >/proc/sys/vm/drop_caches" &
                    done # end of ip
                    sleep 5
                done # end of nj
            done # end of iodepth
        done # end of rw
    done #end of bs

    for rw in randrw
    do
        sleep 5
        #for bs in 4k 8k 64k 512k 4M 8M
        for bs in 4k 8k 64k 512k
        do
            for iodepth in 1
            do
                for nj in 1
                do
                    for ip in ${host}
                    do
                        ssh root@${ip} "fio -thread -ioengine=libaio -group_reporting -name=mytest -randrepeat=0 -time_based -runtime=300 -direct=1 -rwmixread=70 --output-format=json --output=${path}/${rw}-${bs}-${iodepth}-${nj}-${ip}.json -filename=/dev/sdi:/dev/sdj -rw=${rw} -bs=${bs} -numjob=${nj} --iodepth=${iodepth} " &
                    done # end of ip
                    sleep 305
                    for ip in ${host}
                    do
                        ssh root@${ip} "echo 3 >/proc/sys/vm/drop_caches" &
                    done # end of ip
                    sleep 5
                done # end of nj
            done # end of iodepth
        done # end of rw
    done #end of bs
}

wait_nmon()
{
    # wait nmon at server nodes
    echo -e "\033[35m waiting server nodes\033[0m"
    sleep 10
}

get_result()
{
    # get result files from server nodes
    echo -e "\033[35m get results file frome server nodes\033[0m"
    for ip in ${host}
    do
        scp root@${ip}:${path}/* ${here}
        ssh root@${ip} "mv ${path}/*.* ${bak}/"
    done

    echo -e "\033[35m Success!\033[0m"
}

useage()
{
    echo "fio_json.sh need a arg as follow:"
    echo "all:      seq, rand, rw cases"
    #echo "clean:    rm all files and dirs in /home/perform_result/"
    #echo "dd:       dd local block devices, being care of devices' name"
    echo "lat:      seq, rand, rw in iodepth=1, nj=1"
    #echo "killfio:  kill fio process on all servers"
    #echo "prepare:  fio randwrite 4k to raise of flush water level"
    echo "rand:     all randwrite and randread cases"
    echo "rw:       all randrw cases"
    echo "seq:      all write and read cases"
}

dd()
{
    for ip in ${host}
    do
        ssh root@${ip} "dd if=/dev/zero of=/dev/sdi bs=1M" &
        ssh root@${ip} "dd if=/dev/zero of=/dev/sdj bs=1M" &
    done # end of ip
}

prepare()
{
    for ip in ${host}
    do
        ssh root@${ip} "fio -thread -ioengine=libaio -group_reporting -name=mytest -randrepeat=0 -time_based -runtime=3000000 -direct=1 -filename=/dev/sdi:/dev/sdj -rw=randwrite -bs=4k -numjob=8 --iodepth=256" &
    done # end of ip
}

clean()
{
    for ip in ${host}
    do
        ssh root@${ip} "rm -rf /home/perform_results/*"
    done # end of ip
}

killfio()
{
    for ip in ${host}
    do
        ssh root@${ip} "pkill -9 fio" &
    done # end of ip
}

# main
if [ $# -lt 1 ]; then
    useage
    exit 1
fi

arg="${1}"
case $arg in
    prepare)
        prepare
        ;;
    dd)
        dd 
        ;;
    seq)
        create_dir
        start_nmon
        seq 
        #wait_nmon
        get_result
        ;;
    rand)
        create_dir
        start_nmon
        rand 
        #wait_nmon
        get_result
        ;;
    rw)
        create_dir
        start_nmon
        rw 
        #wait_nmon
        get_result
        ;;
    lat)
        create_dir
        start_nmon
        lat 
        #wait_nmon
        get_result
        ;;
    all)
        create_dir
        start_nmon
        seq 
        sleep 60
        rand 
        sleep 60
        rw 
        sleep 60
        #wait_nmon
        get_result
        ;;
    clean)
        clean
        ;;
    *)
        useage
        exit 1
        ;;
esac

