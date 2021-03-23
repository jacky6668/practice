#!/bin/bash
# -------------------------------------------------------------------------------
# Revision:    1.0
# Date:        2019/08/12
# Author:      chenyibo2@jd.com
# Description: daily build test
# Copyright:   2019 (c) jd.com
# -------------------------------------------------------------------------------

set -ex

client="
"

killscreen() {
	for i in ${client};
	do
		ssh root@${i} "screen -ls | grep -E \"vdbench|test|mdtest|fstst|fsbench|rand|mdscheck\"| awk '{print \$1}' | xargs -I {} screen -S {} -X quit"
	done
	sudo rm -rf /root/mds-check-log
}

#clean cluste1 vol
cleancluster() {
	ssh root@<IP> "~/yibo/cleancluster1.sh"
}

#build
build() {
cd /export/jcloud-cfs/src/jd.com/zfs
/export/jcloud-cfs/src/jd.com/zfs/tool/package.sh clean
/export/jcloud-cfs/src/jd.com/zfs/tool/package.sh build
}

#deploy
deploy() {
cd /root/cfs-ansible
./bin/rebuild.sh -i inventories/44
}

#start test
runtest() {
	ssh -t root@192.168.245.139 "cd ~/CfsBench/vdbench/; screen -dmS vdbench; screen -x -S vdbench -p 0 -X stuff ./runvdbench.sh'\n'"
	ssh -t root@192.168.245.143 "cd ~/CfsBench/vdbench/; screen -dmS vdbench; screen -x -S vdbench -p 0 -X stuff ./runvdbench.sh'\n'"
	ssh -t root@192.168.245.106 "cd mdtest/; screen -dmS mdtest; screen -x -S mdtest -p 0 -X stuff ./runmdtest.sh'\n'"
	ssh -t root@192.168.245.170 "cp loop_fstest.sh /mnt/;cd /mnt; screen -dmS fstest; screen -x -S fstest -p 0 -X stuff ./loop_fstest.sh'\n'"
	ssh -t root@192.168.245.170 "screen -dmS fsbench; screen -x -S fsbench -p 0 -X stuff ./runfsbench.sh'\n'"
	sleep 600
	ssh -t root@192.168.245.44 "screen -dmS rand; screen -x -S rand -p 0 -X stuff /root/runrand.sh'\n'"
	ssh -t root@192.168.245.44 "screen -dmS mdscheck; screen -x -S mdscheck -p 0 -X stuff /root/runmdscheck.sh'\n'"
}

# -------------------------------------------------------------------------------
#main
# -------------------------------------------------------------------------------
starttime=`date +'%Y-%m-%d %H:%M:%S'`
start_seconds=$(date --date="$starttime" +%s)

killscreen
cleancluster
build
deploy
runtest

endtime=`date +'%Y-%m-%d %H:%M:%S'`
end_seconds=$(date --date="$endtime" +%s)
echo "runtime:  "$((end_seconds-start_seconds))"s"
