#!/bin/bash

set -x 

start_iperf_server(){
    ssh -t root@10.211.80.100 "screen -dmS iperf_server1; screen -x -S iperf_server1 -p 0 -X stuff 'iperf3 -s -p 5201''\n'"
    ssh -t root@10.211.80.100 "screen -dmS iperf_server2; screen -x -S iperf_server2 -p 0 -X stuff 'iperf3 -s -p 5202''\n'"
    ssh -t root@10.211.80.100 "screen -dmS iperf_server3; screen -x -S iperf_server3 -p 0 -X stuff 'iperf3 -s -p 5203''\n'"
    ssh -t root@10.211.80.100 "screen -dmS iperf_server4; screen -x -S iperf_server4 -p 0 -X stuff 'iperf3 -s -p 5204''\n'"
}

start_iperf_client(){
    ssh -t root@10.211.80.101 "screen -dmS iperf_client1; screen -x -S iperf_client1 -p 0 -X stuff 'iperf3 -c 10.211.80.100 -p 5201 -t 86400''\n'"
    ssh -t root@10.211.80.102 "screen -dmS iperf_client2; screen -x -S iperf_client2 -p 0 -X stuff 'iperf3 -c 10.211.80.100 -p 5202 -t 86400''\n'"
    ssh -t root@10.211.80.103 "screen -dmS iperf_client3; screen -x -S iperf_client3 -p 0 -X stuff 'iperf3 -c 10.211.80.100 -p 5203 -t 86400''\n'"
    ssh -t root@10.211.80.99  "screen -dmS iperf_client4; screen -x -S iperf_client4 -p 0 -X stuff 'iperf3 -c 10.211.80.100 -p 5204 -t 86400''\n'"
}

down_and_up_net(){
    net_list=(eth0 eth1)
    #while
    for i in {1..2}
    do
        index=$(($RANDOM%${#net_list[@]}))
        net=${net_list[$index]}
        echo "now test ${net}"
        ifconfig ${net} down
        sleep 60
        ifconfig ${net} up
    done
}


#############main
start_iperf_server
start_iperf_client
#down_and_up_net
