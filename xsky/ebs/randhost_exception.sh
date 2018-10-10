#!/bin/bash


#This is the script definition variable

node_ip=(10.252.3.xxx 10.252.3.xxx 10.252.3.xxx)
public_network=`xms-cli -f '{{range .}}{{println .network_interface.name}}{{end}}' --user admin --password admin network-address list -q "roles:public AND host.name:$(hostname)"`  	#This is the public network
cluster_network=`xms-cli -f '{{range .}}{{println .network_interface.name}}{{end}}' --user admin --password admin network-address list -q "roles:private AND host.name:$(hostname)"`	#This is the cluster network
Net_class=`ip addr |grep "state UP" | awk -F ":" '{print $2}'| grep -v @` #This Net class speed

run_public_count="0"		#public network Use case run count variables
run_cluster_count="0"		#cluster network Use case run count variables
run_xdc_count="0"		#xdc service Use case run count variables
run_disk_count="0"		#disk abnormal Use case run count variables
run_power_count="0"		#power Use case run count variables
run_public_flashing_count="0"            #public network Use case run count variables
run_cluster_flashing_count="0"           #cluster network Use case run count variables
run_stop_osd_count="0"          #stop osd service Use case run count variables
run_stop_mon_count="0"		#stop mon service Use case run count variables
run_stop_xmsd_count="0"		#stop xmsd service Use case run count variables
run_kill_mon_count="0"
run_kill_osd_count="0"
run_kill_osds_count="0"
run_kill_xdc_count="0"
run_kill_etcd_count="0"
run_kill_EtcdProxy_count="0"

log_file=$(date -d "today" +"%Y%m%d_%H%M%S").log
log_dir=/home/$log_file	#log file 


public_flashing_count=0		#Case execution COUNT
cluster_flashing_count=0	#Case execution COUNT
public_count=0			#Case execution COUNT
cluster_count=0			#Case execution COUNT
xdc_count=0			#Case execution COUNT
disk_count=0			#Case execution COUNT
power_count=0			#Case execution COUNT
stop_osd_count=0		#Case execution COUNT
stop_mon_count=0		#Case execution COUNT
stop_xmsd_count=0		#Case execution COUNT
kill_mon_count=0
kill_osd_count=0
kill_osds_count=0
kill_xdc_count=0
kill_etcd_count=0
kill_EtcdProxy_count=0

#Net class speed
Net_class_speed()
{
	for i in $Net_class
	do
		echo $i IP : $(ifconfig $i | grep inet | cut -f 2 -d ":" | awk -F " " '{print $2}')
		echo $(ethtool $i | grep Speed)
	done

}

#Create log files
create_dir()
{
    echo -e "\033[35m start Exception test\033[0m"
    # create runing  at this server
    if [ -f ${log_dir} ]
    then
        echo -e "\033[31m ${runing_log} is already existed\033[0m"
	echo > $log_dir
	echo Please go to ${runing_log} log to view the running content
	echo This $log_dir Content to empty
    else
	cd /home/
	touch $log_file
	cd /root/
        echo -e "\033[32m ${runing_log} has been created\033[0m"
    fi
}

#sleep time 
Sleep_Time(){
        echo $(($RANDOM%600+150)) 
}

#down public netwrok
down_public()
{ 
	run_public_count=$(expr $run_public_count + 1)
        # NetWork_downPublic_case
        echo  \## start NetWork_downPublic_case public network is $public_network
	echo down_network on $public_network 
        ifconfig $public_network down
        date
        echo sleep 300 Second
        sleep 300
        echo up_network on $public_network
        ifconfig $public_network up
        echo The NetWork_down_case is END ===========================
        echo sleep 600 Second
        sleep 600
	public_count=$[$public_count+1]
}

public_flashing()
{
        run_public_flashing_count=$(expr $run_public_flashing_count + 1)
        # NetWork_downPublic_case
        echo  \## start NetWork_downPublic_flashing_case public network is $public_network
        echo down_network on $public_network 
        ifconfig $public_network down
        date
        echo sleep 3 Second
        sleep 3
        echo up_network on $public_network
        ifconfig $public_network up
        echo The NetWork_down_flashing_case is END ===========================
        echo sleep 2 Second
        sleep 2
        public_flashing_count=$[$public_flashing_count+1]
}

#down cluster network 
down_cluster()
{
	run_cluster_count=$(expr $run_cluster_count + 1)
	# NetWokr_dowCluster_case
        echo \## start NetWokr_Down_Cluster_case cluster network  $cluster_network
        echo down_network on $cluster_network
        ifconfig $cluster_network down
        date
        echo sleep 300 Second
        sleep 300
        echo up_network on $cluster_network
        ifconfig $cluster_network up
        echo The NetWork_downCluster_case $cluster_networkis END ==================================
        echo sleep 600 Second
        sleep 600
	cluster_count=$[$cluster_count+1]
}

cluster_flashing()
{
        run_cluster_flashing_count=$(expr $run_cluster_flashing_count + 1)
        # NetWokr_dowCluster_case
        echo \## start NetWokr_Down_Cluster_flashing_case cluster network  $cluster_network
        echo down_network on $cluster_network
        ifconfig $cluster_network down
        date
        echo sleep 3 Second
        sleep 3
        echo up_network on $cluster_network
        ifconfig $cluster_network up
        echo The NetWork_downCluster_flashing_case $cluster_networkis END ==================================
        echo sleep 2 Second
        sleep 2
        cluster_flashing_count=$[$run_cluster_flashing_count+1]

}

#stop xdc service
stop_xdc()
{
	run_xdc_count=$(expr $run_xdc_count + 1)
	echo \## start Stop Xdc Service case
	echo stop xdc.server runing 
        systemctl stop xdc.service
        echo sleep 120 Second
        sleep 120
        echo xdc service status
        systemctl status xdc.service | grep Active | awk -F: '{print $2}'|  awk '{print $2}'
        echo The StopXdc Service case is END ==========================================
	xdc_count=$[$xdc_count+1]
}

# stop ceph-osd serveice
stop_osd()
{
	run_stop_osd_count=$(expr $run_stop_osd_count + 1)
	echo \## start stop ceph_osd service case
	echo stop ceph-osd server runing
	systemctl stop ceph-osd.target
	sleep_time=`Sleep_Time`
	echo sleep $sleep_time
	sleep $sleep_time
	status=`systemctl status ceph-osd.target | grep Active | awk -F: '{print $2}' | awk '{print $1}'`
	echo osd service status: $status 
	echo The Stop osd service case is END ========================================
	stop_osd_count=$[$stop_osd_count + 1]
}

# stop mon service
stop_mon()
{
	run_stop_mon_count=$(expr $run_stop_mon_count + 1)
        echo \## start stop ceph_mon service case
        echo stop ceph-mon server runing
        systemctl stop ceph-mon.target
        sleep_time=`Sleep_Time`
        echo sleep $sleep_time
        sleep $sleep_time
        status=`systemctl status ceph-mon.target | grep Active | awk -F: '{print $2}' | awk '{print $1}'`
        echo mon service status: $status 
        echo The Stop mon service case is END ========================================
        stop_mon_count=$[$stop_mon_count + 1]

}

# stop xmsd service
stop_xmsd()
{
	run_stop_xmsd_count=$(expr $run_stop_xmsd_count + 1)
	echo \## start stop xmsd service case
	echo stop xmsd server runing
	systemctl stop xmsd.service
	sleep_time=`Sleep_Time`
	echo sleep $sleep_time
	sleep $sleep_time
	systemctl start xmsd.service
	sleep 5
	status=`systemctl status xmsd.service | grep Active | awk -F: '{print $2}' | awk '{print $1}'`
	echo xmsd service status: $status
	echo The stop xmsd sercie case is END ========================================
	stop_xmsd_cout=$[$stop_xmsd_count + 1]
}

# kill mon service
kill_mon()
{
	run_kill_mon_count=$(expr $run_kill_mon_count + 1)
	echo \## start kill mon service case 
	echo kill mon server runing
	mon_Id=`ps -ef | grep ceph-mon | grep -v 'color=auto'| awk -F ' ' '{print $2}'`
	kill -9 $mon_Id
	sleep_time=`Sleep_Time`
	echo sleep $sleep_time
	sleep $sleep_time
	status=`systemctl status ceph-mon.target | grep Active | awk -F: '{print $2}' | awk '{print $1}'`
	echo mon service status: $status 
	echo The kill  mon service case is END ========================================
	kill_mon_count=$[kill_mon_count +1]
}

# kill osd service
kill_osd()
{
	run_kill_osd_count=$(expr $run_kill_osd_count + 1)
	echo \## start kill osd service case	
	echo kill osd server runing	
	ps -ef | grep ceph-osd | grep -v 'color=auto' | awk -F ' ' '{print $2}' > /root/osd_pid	
	osd_Id=`shuf -n1 /root/osd_pid`
	kill -9 $osd_Id
	sleep_time=`Sleep_Time`
        echo sleep $sleep_time
        sleep $sleep_time
	status=`ceph -s | grep osdmap`
	echo osd status is: $status
	echo The kill osd service case is END ========================================
	kill_osd_count=$[$kill_osd_count +1]
}

kill_osds()
{
	run_kill_osds_count=$(expr $run_kill_osds_count + 1)
        echo \## start kill osds service case    
        echo kill osds server runing
	ps -ef | grep ceph-osd | grep -v 'color=auto' | awk -F ' ' '{print $2}' > /root/osd_pid
	
	for i in `cat /root/osd_pid`
	do
		kill -9 $i
	done
	sleep_time=`Sleep_Time`
        echo sleep $sleep_time
        sleep $sleep_time
	status=`ceph -s | grep osdmap`
        echo osd status is: $status
        echo The kill osds service case is END ========================================
        kill_osds_count=$[$kill_osds_count +1]
}

# kill xdc
kill_xdc()
{
	run_kill_xdc_count=$(expr $run_kill_xdc_count + 1)
	echo kill xdc server runing
    #check xdc_service PID
    ps -ef | grep -w '/usr/bin/xdcd'| grep -Ev 'color|grep|watch' | awk -F ' ' '{print $2}' > /root/xdc_pid
	xdc_Id=`head -1 /root/xdc_pid`
	kill -9 $xdc_Id
	sleep_time=`Sleep_Time`
        echo sleep $sleep_time
        sleep $sleep_time
	status=`ps -ef | grep xdc | grep -v 'color=auto' | awk -F ' ' '{print $2}'| wc -l`
	echo xdc server pid : $status
	echo The kill xdc service case is END ========================================
	kill_xdc_count=$[$kill_xdc_count +1]
} 

# kill etcd
kill_etcd()
{
	run_kill_etcd_count=$(expr $run_kill_etcd_count + 1)
	echo kill etcd runing
	etcd_Id=`ps -ef | grep etcd.conf | grep -v 'color=auto'| awk -F ' ' '{print $2}'`
	kill -9 $etcd_Id
	sleep_time=`Sleep_Time`
        echo sleep $sleep_time
        sleep $sleep_time
	status=`ps -ef | grep etcd.conf | grep -v 'color=auto'| awk -F ' ' '{print $2}'|wc -l`
	echo etcd pid : $status
	echo The kill etcd case is END ========================================
	xdc_kill_etcd_count=$[$kill_etcd_count +1]
}

# kill etcd-proxy
kill_etcd_proxy()
{
	run_kill_EtcdProxy_count=$(expr $run_kill_EtcdProxy_count + 1)
        echo kill etcd-proxy runing
        etcd_Id=`ps -ef | grep etcd-proxy.conf | grep -v 'color=auto'| awk -F ' ' '{print $2}'`
        kill -9 $etcd_Id
        sleep_time=`Sleep_Time`
        echo sleep $sleep_time
        sleep $sleep_time
        status=`ps -ef | grep etcd-proxy.conf | grep -v 'color=auto'| awk -F ' ' '{print $2}'|wc -l`
        echo etcd pid : $status
        echo The kill etcd-proxy case is END ========================================
        xdc_kill_EtcdProxy_count=$[$kill_EtcdProxy_count +1]
}

# osd status
osd_status()
{
	osd_osds=$(ceph -s | grep osdmap | awk -F : '{print $2}'| awk -F " " '{print $1}')
        osd_up=$(ceph -s | grep osdmap | awk -F : '{print $3}'| awk -F " " '{print $1}')
        osd_in=$(ceph -s | grep osdmap | awk -F "," '{print $2}'| awk -F " " '{print $1}')

	while [ $osd_up -ne $osd_osds ]
	do	
		if [ $osd_up -eq $osd_osds ] || [ $osd_up -eq $osd_in ]
		then
			break
		else
			echo osd is starting.......
                        osd_osds=$(ceph -s | grep osdmap | awk -F : '{print $2}'| awk -F " " '{print $1}')
                        osd_up=$(ceph -s | grep osdmap | awk -F : '{print $3}'| awk -F " " '{print $1}')
                        osd_in=$(ceph -s | grep osdmap | awk -F "," '{print $2}'| awk -F " " '{print $1}')
			continue
		fi
	done
	echo "`date "+%Y-%m-%d %H:%M:%S"`" : " The osd status is:"  >>  $log_dir
	echo "`date "+%Y-%m-%d %H:%M:%S"`" : " osd number is : $osd_osds"  >>  $log_dir
	echo "`date "+%Y-%m-%d %H:%M:%S"`" : " osd up_status : $osd_up"  >>  $log_dir
	echo "`date "+%Y-%m-%d %H:%M:%S"`" : " osd up_in  is : $osd_in"  >>  $log_dir
	echo -e "\033[31m Osd Status: \033[0m"
	echo -e "\033[33m osd number is : $osd_osds \033[0m"
        echo -e "\033[33m osd up_status : $osd_up \033[0m"
        echo -e "\033[33m osd up_in  is : $osd_in \033[0m"
}



# disk abnormal case
disk_abnormal()
{
	rum_disk_count=$(expr $rum_disk_count + 1)
	echo \## start disk_abnormal case
        rm -rf /root/iscsi_id
	
	lsblk | grep ceph | grep -e omap -e osd | awk '{print $1}' | awk -F ─ '{print $2}' | awk -F 1 '{print $1}' > /root/ceph_disk
	lsblk | grep ceph | grep  omap | awk '{print $1}' | awk -F ─ '{print $2}' | awk -F 1 '{print $1}' > /root/ceph_ssd_disk
	
	ssd_disk=`awk '{print NR}' /root/ceph_ssd_disk`
	
	for j in $ssd_disk
	do
		ssd_disk_id=`sed -n "$j p" /root/ceph_ssd_disk`
		sed -i "3 i $ssd_disk_id " /root/ceph_disk
	done
	for j in `cat /root/ceph_disk`
	do
		lsscsi | grep $j | awk -F "]" '{print $1}' | awk -F "[" '{print $2}' | awk -F : '{print $0}' >> /root/iscsi_id
	done	
	
	
	sed -i s/:/" "/g /root/iscsi_id
	count=`awk '{print NR}' /root/iscsi_id`

#	ssd_count=`awk '{print NR}' /root/ceph_ssd_id`	
#	lsblk | grep ceph | grep -e omap -e osd | awk '{print $1}' | awk -F ─ '{print $2}' | awk -F 1 '{print $1}'
	
        for q in $count
        do
                id=`awk NR==$q'{print $0}' /root/iscsi_id`
                echo "`date "+%Y-%m-%d %H:%M:%S"` : $id down"  >>  $log_dir
		echo `date "+%Y-%m-%d %H:%M:%S"` : $id down
                echo "scsi remove-single-device $id" > /proc/scsi/scsi
                echo sleep 60 Second
                sleep 30
		echo "`date "+%Y-%m-%d %H:%M:%S"`" : $id up >> $log_dir
		echo `date "+%Y-%m-%d %H:%M:%S"` : $id up
                echo "scsi add-single-device $id" > /proc/scsi/scsi
		osd_status
                sleep_time=`Sleep_Time`
		echo sleep time:$sleep_time Second
		sleep $sleep_time
        done
        echo The  disk_abnormal case is END ===========================
	disk_count=$[$disk_count+1]
}

Pull_out_Hdd(){
	rm -rf /root/iscsi_id
	lsblk | grep osd | awk '{print $1}' | awk -F ─ '{print $2}' | awk -F 1 '{print $1}' > /root/hdd_disk

	for n in `cat /root/hdd_disk`
	do
		lsscsi | grep $n | awk -F "]" '{print $1}' | awk -F "[" '{print $2}' | awk -F : '{print $0}' >> /root/iscsi_id
	done
	sed -i s/:/" "/g /root/iscsi_id
	
	for m in {1..1000000}
	do
		Hdd_disk_id=`shuf -n1 iscsi_id`
		echo "`date "+%Y-%m-%d %H:%M:%S"`" : $Hdd_disk_id down  >>  $log_dir
		echo `date "+%Y-%m-%d %H:%M:%S"` : $Hdd_disk_id down
		echo "scsi remove-single-device $Hdd_disk_id" > /proc/scsi/scsi 
		echo sleep 30 Second
		sleep 30
		echo "`date "+%Y-%m-%d %H:%M:%S"`" : $Hdd_disk_id up  >>  $log_dir
		echo `date "+%Y-%m-%d %H:%M:%S"` : $Hdd_disk_id up
		echo "scsi add-single-device $Hdd_disk_id" > /proc/scsi/scsi 
		osd_status
		sleep_time=`Sleep_Time`
		echo sleep time:$sleep_time Second
		sleep $sleep_time
	done
}

Pull_out_ssd(){
	rm -rf /root/iscsi_id
	lsblk | grep ceph | grep  omap | awk '{print $1}' | awk -F ─ '{print $2}' | awk -F 1 '{print $1}' > /root/ceph_ssd_disk
	
	for s in `cat /root/ceph_ssd_disk`
	do
		lsscsi | grep $s | awk -F "]" '{print $1}' | awk -F "[" '{print $2}' | awk -F : '{print $0}' >> /root/iscsi_id
	done
	sed -i s/:/" "/g /root/iscsi_id
	
	for y in {1..1000000}
	do
		ssd_disk_id=`shuf -n1 iscsi_id`
		echo "`date "+%Y-%m-%d %H:%M:%S"`" : $ssd_disk_id down  >>  $log_dir
		echo `date "+%Y-%m-%d %H:%M:%S"` : $ssd_disk_id down
		echo "scsi remove-single-device $ssd_disk_id" > /proc/scsi/scsi
		echo sleep 30 Second
                sleep 30
		echo "`date "+%Y-%m-%d %H:%M:%S"`" : $ssd_disk_id up  >>  $log_dir
		echo `date "+%Y-%m-%d %H:%M:%S"` : $ssd_disk_id up
                echo "scsi add-single-device $ssd_disk_id" > /proc/scsi/scsi
		osd_status
		sleep_time=`Sleep_Time`
		echo sleep time:$sleep_time Second
                sleep $sleep_time
	done
}


# power down
power_down(){
run_power_count=$(expr $run_power_count + 1)
server_ip=$1
interval=180
for i in `seq 1 1000000`
do
        ping $server_ip -c 1  > /dev/null 2>&1
        if [ $? -gt 0 ]
        then
		echo no 
                sleep 10
                continue
        else
		echo yes
                sleep $interval
                date
                nohup ssh $server_ip "echo c > /proc/sysrq-trigger" &
                sleep 10
        fi
done
power_count=$[$power_count+1]
}

reboot(){
reboot_ip=$1
echo $reboot_ip
for i in `seq 1 1000000`
do
        ping $reboot_ip -c 1  > /dev/null 2>&1
        if [ $? -gt 0 ]
        then
                echo ping ok 
                sleep 10
                continue
        else
                echo ping ok, sleep 180 s
		sleep 180
                date
		echo reboot now !!!
                nohup ssh $reboot_ip "reboot" &
                sleep 10
        fi
done
}

#statistical information
summry()
{
	echo "~~~~~~summry~~~~~~" >> $log_dir
        echo "public_count=$public_count" >> $log_dir
        echo "cluster_count=$cluster_count" >> $log_dir
        echo "xdc_count=$xdc_count" >> $log_dir
        echo "disk_count=$disk_count" >> $log_dir
	echo "public_flashing_count=$public_flashing_count" >> $log_dir
	echo "cluster_flashing_count=$cluster_flashing_count" >> $log_dir
	echo "power_down_count=$power_count" >> $log_dir
	echo "stop_osd_count=$stop_osd_count" >> $log_dir
	echo "stop_xmsd_count=$stop_xmsd_count" >> $log_dir
	echo "kill_mon_count=$kill_mon_count" >> $log_dir
	echo "kill_osd_count=$kill_osd_count" >> $log_dir
	echo "kill_osds_count=$kill_osds_count" >> $log_dir
	echo "kill_xdc_count=$kill_xdc_count" >> $log_dir
	echo "kill_etcd_count=$kill_etcd_count" >> $log_dir
	echo "kill_EtcdProxy_count=$kill_EtcdProxy_count" >> $log_dir
}



#Random execution
rand_case()
{
	array=(down_public stop_mon disk_abnormal stop_osd down_cluster stop_xdc  public_flashing kill_mon  cluster_flashing kill_osd kill_osds kill_xdc kill_etcd kill_etcd_proxy power_down reboot)
	#echo "array is $array"
	#echo "array[1] is ${array[1]}"

	index=$(($RANDOM%${#array[@]}))
	#echo $index
	echo "" >> $log_dir
	echo "`date "+%Y-%m-%d %H:%M:%S"`" : " ==================== ${array[$index]} Start  ===================="  >>  $log_dir 
	${array[$index]}
	summry
	echo "`date "+%Y-%m-%d %H:%M:%S"` ": " ==================== ${array[$index]} Finish  ===================="  >> $log_dir 
}
		

rand_ip(){
for i in {1..100000}
do
        echo "for loop:$i"
        sleep 150 
	array=(down_public stop_mon disk_abnormal stop_osd down_cluster stop_xdc  public_flashing kill_mon  cluster_flashing kill_osd kill_osds kill_xdc kill_etcd kill_etcd_proxy power_down reboot)
	in=$(($RANDOM%${#array[@]}))
	aa=${array[$in]}

        index=$(($RANDOM%${#node_ip[@]}))
	ip=${node_ip[$index]}
        if [ $aa = power_down ]
        then           
            echo "`date "+%Y-%m-%d %H:%M:%S"` "": power_down is $ip" >> $log_dir
	    ssh $ip "echo c > /proc/sysrq-trigger" &
        elif [ $aa = reboot ]
        then
            echo "`date "+%Y-%m-%d %H:%M:%S"` "": reboot is $ip" >> $log_dir 
            ssh $ip "reboot" &
        else
            echo "`date "+%Y-%m-%d %H:%M:%S"` "": $ip abnormal: $aa" >> $log_dir
            ssh root@$ip "sh randhost_exception.sh.sh $aa"
        fi
        sleep 18000
done
}

#seq_count()
#{
#intavl=$1
#for i in `seq 1 $intavl`
#do
#	echo run seq count is $i
#	create_dir
#	down_public
#	disk_abnormal
#	down_cluster
#	stop_xdc
#done
#}

#rand_count()
#{
#intavl=$1

#for i in `seq 1 1000000`
#do
#	echo Run Test Case is $i
#	create_dir	
#	rand_case
#done

#}

#
prompt_message()
{
	echo -e "\033[5;41m You need to specify parameters for the script!!\033[0m"
	echo -e "\033[33m mixed_case.sh need two arg as follow!!! \033[0m"
	echo -e "\033[31m Optional parameters: \033"
	echo -e "\033[33m disk  		--This is the disk exception parameter \033[0m"
	echo -e "\033[33m cluster	--This is the cluster network parameter \033[0m"
	echo -e "\033[33m public		--This is the broken public network parameter \033[0m"
	echo -e "\033[33m xdc		--This is the Stop_xdc parameters \033[0m"
	echo -e "\033[33m public_flash   --This is the flash public_network parameter \033[0m"
	echo -e "\033[33m cluster_flash	--This is the flash cluster network parameter \033[0m"
	echo -e "\033[33m net_speed	--This is the display network speed record parameter\033[0m"
	echo -e "\033[33m power_down	--This is the power exception parameter	\033[0m"
	echo -e "\033[33m pull_out_hdd   --This is the Pull_out_Hdd  exception parameter \033[0m"
	echo -e "\033[33m pull_out_ssd   --This is the Pull_out_ssd  exception parameter \033[0m"
	echo -e "\033[33m stop_osd       --This is the stop ceph-osd  exception parameter \033[0m"
	echo -e "\033[33m stop_mon       --This is the stop ceph-mon exception parameter \033[0m"
	echo -e "\033[33m stop_xmsd      --This is the stop xmsd exception parameter \033[0m"
	echo -e "\033[33m kill_mon	 --This is the kill mon exception parameter \033[0m"
	echo -e "\033[33m kill_osd       --This is the kill osd exception parameter \033[0m"
	echo -e "\033[33m kill_osds       --This is the kill osds exception parameter \033[0m"
	echo -e "\033[33m kill_xdc       --This is the kill xdc exception parameter \033[0m"
	echo -e "\033[33m kill_etcd       --This is the kill etcd exception parameter \033[0m"
	echo -e "\033[33m kill_etcd_proxy       --This is the kill etcd-proxy  exception parameter \033[0m"
	echo -e "\033[33m reboot 	--This is the reboot host \033[0m"
	echo -e "\033[33m rand 		-- In the use case, randomly select an exception use case to execute an exception on the current node \033[0m"
	echo -e "\033[33m rand_ip               -- Random exceptions are made within the specified IP range \033[0m"
	echo ""
	echo -e "\033[31m syntax: \033[0m"
	echo -e " \033[33m ./mixed_case.sh parameter OR sh mixed_case.sh parameter\033[0m"
	echo ""
	echo -e "\033[31m Example: \033[0m"
	echo -e " \033[33m ./mixed_case.sh disk_abnormal\033  \033[33m  or \033[0m \033[33m ./mixed_case.sh rand\033[0m"
	echo -e " \033[33m sh mixed_case.sh disk_abnormal\033  \033[33m  or \033[0m \033[33m sh mixed_case.sh rand\033[0m"
}
if [ $# -lt 1 ];then
	prompt_message
	exit 1
fi

arg=$1
param=$2
create_dir
case $arg in
#	seq)
#	   seq_count $param
#	   ;;
	public)
		echo for loop Count: $i 
		echo "" >> $log_dir
		echo "`date "+%Y-%m-%d %H:%M:%S"`" : " ==================== down_public Start  ===================="  >>  $log_dir
		down_public
		summry
                echo "`date "+%Y-%m-%d %H:%M:%S"` ": " ==================== down_public Finish  ===================="  >> $log_dir
		;;
	cluster)
		echo for loop Count: $i
		echo "" >> $log_dir
		echo "`date "+%Y-%m-%d %H:%M:%S"`" : " ==================== down_cluster Start  ===================="  >>  $log_dir
		down_cluster
		summry
                echo "`date "+%Y-%m-%d %H:%M:%S"` ": " ==================== down_cluster Finish  ===================="  >> $log_dir
		;;
	xdc)
		echo for loop Count: $i
		echo "" >> $log_dir
		echo "`date "+%Y-%m-%d %H:%M:%S"`" : " ==================== stop_xdc Start  ===================="  >>  $log_dir
                stop_xdc
	        summry
                echo "`date "+%Y-%m-%d %H:%M:%S"` ": " ==================== stop_xdc Finish  ===================="  >> $log_dir
                ;;
	disk)
		rm -rf /var/crash/core.ceph-osd*
		echo for loop Count: $i
		echo "" >> $log_dir
		echo "`date "+%Y-%m-%d %H:%M:%S"`" : " ==================== disk_abnormal Start  ===================="  >>  $log_dir
		disk_abnormal
		summry
        	echo "`date "+%Y-%m-%d %H:%M:%S"` ": " ==================== disk_abnormal Finish  ===================="  >> $log_dir
		;;
	public_flash)
                echo for loop Count: $i
		echo "" >> $log_dir
                echo "`date "+%Y-%m-%d %H:%M:%S"`" : " ==================== public_flash Start  ===================="  >>  $log_dir
                public_flashing
                summry
                echo "`date "+%Y-%m-%d %H:%M:%S"` ": " ==================== public_flash Finish  ===================="  >> $log_dir
		;;
	cluster_flash)
                echo for loop Count: $i
                echo "" >> $log_dir
                echo "`date "+%Y-%m-%d %H:%M:%S"`" : " ==================== cluster_flash Start  ===================="  >>  $log_dir
                cluster_flashing
                summry
                echo "`date "+%Y-%m-%d %H:%M:%S"`": " ==================== cluster_flash Finish  ===================="  >> $log_dir
		;;
	net_speed)
		Net_class_speed
		;;
	power_down)
	        echo for loop Count: $i
		echo "" >> $log_dir
		echo "`date "+%Y-%m-%d %H:%M:%S"`" : " ==================== power_down is  Start  ===================="  >>  $log_dir
		power_down $param
		summry
		echo "`date "+%Y-%m-%d %H:%M:%S"`": " ==================== power_down is  Finish  ===================="  >> $log_dir
		;;
	pull_out_hdd)
	        echo for loop Count: $i
                echo "" >> $log_dir
                echo "`date "+%Y-%m-%d %H:%M:%S"`" : " ==================== Pull_out_Hdd is  Start  ===================="  >>  $log_dir
		pull_out_Hdd
		echo "`date "+%Y-%m-%d %H:%M:%S"`": " ==================== Pull_out_Hdd is  Finish  ===================="  >> $log_dir
		;;
	pull_out_ssd)
	        echo for loop Count: $i
                echo "" >> $log_dir
                echo "`date "+%Y-%m-%d %H:%M:%S"`" : " ==================== Pull_out_ssd is  Start  ===================="  >>  $log_dir
                Pull_out_ssd
		echo "`date "+%Y-%m-%d %H:%M:%S"`": " ==================== Pull_out_ssd is  Finish  ===================="  >> $log_dir
                ;;
	stop_osd)
                echo for loop Count: $i
                echo "" >> $log_dir
                echo "`date "+%Y-%m-%d %H:%M:%S"`" : " ==================== stop_osd Start  ===================="  >>  $log_dir
                stop_osd
                summry
                echo "`date "+%Y-%m-%d %H:%M:%S"` ": " ==================== stop_osd Finish  ===================="  >> $log_dir
                ;;
	stop_mon)
                echo for loop Count: $i
                echo "" >> $log_dir
                echo "`date "+%Y-%m-%d %H:%M:%S"`" : " ==================== stop_mon Start  ===================="  >>  $log_dir
                stop_mon
                summry
                echo "`date "+%Y-%m-%d %H:%M:%S"` ": " ==================== stop_mon Finish  ===================="  >> $log_dir
                ;;
	stop_xmsd)
                echo for loop Count: $i
                echo "" >> $log_dir
                echo "`date "+%Y-%m-%d %H:%M:%S"`" : " ==================== stop_xmsd Start  ===================="  >>  $log_dir
                stop_xmsd
                summry
                echo "`date "+%Y-%m-%d %H:%M:%S"` ": " ==================== stop_xmsd Finish  ===================="  >> $log_dir
                ;;
	kill_mon)
                echo for loop Count: $i
                echo "" >> $log_dir
                echo "`date "+%Y-%m-%d %H:%M:%S"`" : " ==================== kill mon Start  ===================="  >>  $log_dir
                kill_mon
                summry
                echo "`date "+%Y-%m-%d %H:%M:%S"` ": " ==================== kill mon Finish  ===================="  >> $log_dir
                ;;
	kill_osd)
                echo for loop Count: $i
                echo "" >> $log_dir
                echo "`date "+%Y-%m-%d %H:%M:%S"`" : " ==================== kill osd Start  ===================="  >>  $log_dir
                kill_osd
                summry
                echo "`date "+%Y-%m-%d %H:%M:%S"` ": " ==================== kill osd Finish  ===================="  >> $log_dir
                ;;
	kill_osds)
                echo for loop Count: $i
                echo "" >> $log_dir
                echo "`date "+%Y-%m-%d %H:%M:%S"`" : " ==================== kill osds Start  ===================="  >>  $log_dir
                kill_osds
                summry
                echo "`date "+%Y-%m-%d %H:%M:%S"` ": " ==================== kill osds Finish  ===================="  >> $log_dir
                ;;
	kill_xdc)
                echo for loop Count: $i
                echo "" >> $log_dir
                echo "`date "+%Y-%m-%d %H:%M:%S"`" : " ==================== kill xdc Start  ===================="  >>  $log_dir
                kill_xdc
                summry
                echo "`date "+%Y-%m-%d %H:%M:%S"` ": " ==================== kill xdc Finish  ===================="  >> $log_dir
                ;;
	kill_etcd)
                echo for loop Count: $i
                echo "" >> $log_dir
                echo "`date "+%Y-%m-%d %H:%M:%S"`" : " ==================== kill etcd Start  ===================="  >>  $log_dir
                kill_etcd
                summry
                echo "`date "+%Y-%m-%d %H:%M:%S"` ": " ==================== kill etcd Finish  ===================="  >> $log_dir
                ;;
	reboot)
		reboot $param
		;;
	kill_etcd_proxy)
                echo for loop Count: $i
                echo "" >> $log_dir
                echo "`date "+%Y-%m-%d %H:%M:%S"`" : " ==================== kill etcd-proxy Start  ===================="  >>  $log_dir
                kill_etcd_proxy
                summry
                echo "`date "+%Y-%m-%d %H:%M:%S"` ": " ==================== kill etcd-proxy Finish  ===================="  >> $log_dir
                ;;

	rand)
	   	for i in {1..1000000}
		do
			echo for loop Count: $i
			rand_case
		done
		;;
        rand_ip)
	        rand_ip
		;;
	*)
	   prompt_message
	   exit 1
	   ;;
esac


