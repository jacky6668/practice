#!/bin/bash
host="
10.252.3.195
10.252.3.196
10.252.3.197
"
## <--EBS Specified variable value-->
debug_xstore=2
debug_osd=2
debug_mon=10
debug_paxos=10
debug_optracker=2
osd_enable_op_tracker="True"

osd_async_recovery_max_updates=10
osd_op_complaint_time=5
osd_op_tracker_dump_lat=5
mutex_stall_strace=3
mutex_stall_strace_2=5
#xstore_mscache_inject_bypass_probability="0.2"
mscache_promote_weight_threshold=1

## <--EOS Specified variable value-->
rgw=2
lc=2
bgt=2
trans=2
obj=2

modify_ebs()
{
for ip in $host
do
    echo -e "\033[31m $ip Began to change \033[0m"
    ssh -T root@$ip "sed -i 's/debug_xstore * = .*/debug_xstore = $debug_xstore/g' /etc/ceph/ceph.conf"
    ssh -T root@$ip "sed -i 's/debug_osd * = .*/debug_osd = $debug_osd/g' /etc/ceph/ceph.conf"
    ssh -T root@$ip "sed -i 's/debug_mon * = .*/debug_mon     = $debug_mon/g' /etc/ceph/ceph.conf"
    ssh -T root@$ip "sed -i 's/debug_paxos  * = .*/debug_paxos      = $debug_paxos/g' /etc/ceph/ceph.conf"
    ssh -T root@$ip "sed -i 's/debug_optracker * = .*/debug_optracker = $debug_optracker/g' /etc/ceph/ceph.conf"
    ssh -T root@$ip "sed -i 's/osd_enable_op_tracker * = .*/osd_enable_op_tracker = $osd_enable_op_tracker/g' /etc/ceph/ceph.conf"
    ssh -T root@$ip "ceph osd pool ls|xargs -I {} ceph osd pool set {} async_recovery_max_updates 10"
    echo -e "Modify:\n    debug_xstore = $debug_xstore\n    debug_osd = $debug_osd\n    debug_mon     = $debug_mon\n    debug_paxos      = $debug_paxos\n    debug_optracker = $debug_optracker"

    ssh -T root@$ip "sed -i 's/osd_async_recovery_max_updates * = .*/osd_async_recovery_max_updates = $osd_async_recovery_max_updates/g' /etc/ceph/ceph.conf"
    ssh -T root@$ip "sed -i 's/osd_op_complaint_time * = .*/osd_op_complaint_time = $osd_op_complaint_time/g' /etc/ceph/ceph.conf"
    ssh -T root@$ip "sed -i 's/osd_op_tracker_dump_lat * = .*/osd_op_tracker_dump_lat = $osd_op_tracker_dump_lat/g' /etc/ceph/ceph.conf"
    ssh -T root@$ip "sed -i 's/mutex_stall_strace * = .*/mutex_stall_strace = $mutex_stall_strace/g' /etc/ceph/ceph.conf"
    ssh -T root@$ip "sed -i 's/mutex_stall_strace_2 * = .*/mutex_stall_strace_2 = $mutex_stall_strace_2/g' /etc/ceph/ceph.conf"
    ssh -T root@$ip "sed -i 's/mscache_promote_weight_threshold * = .*/mscache_promote_weight_threshold = $mscache_promote_weight_threshold/g' /etc/ceph/ceph.conf"
    ssh -T root@$ip "sed -i 's/xstore_mscache_inject_bypass_probability * = .*/xstore_mscache_inject_bypass_probability = $xstore_mscache_inject_bypass_probability/g' /etc/ceph/ceph.conf"
    echo -e "Add:\n    osd_async_recovery_max_updates = $osd_async_recovery_max_updates\n    osd_op_complaint_time = $osd_op_complaint_time\n    osd_op_tracker_dump_lat = $osd_op_tracker_dump_lat\
        \n    mutex_stall_strace = $mutex_stall_strace\n    mutex_stall_strace_2 = $mutex_stall_strace_2\n    mscache_promote_weight_threshold = $mscache_promote_weight_threshold\n    xstore_mscache_inject_bypass_probability = $xstore_mscache_inject_bypass_probability"
done
}

add_ebs(){
for ip in $host
do
    echo -e "\033[31m $ip Began to change \033[0m"
    ssh -T root@$ip "sed -i 's/debug_xstore * = .*/debug_xstore = ${debug_xstore}/g' /etc/ceph/ceph.conf"
    ssh -T root@$ip "sed -i 's/debug_osd * = .*/debug_osd = $debug_osd/g' /etc/ceph/ceph.conf"
    ssh -T root@$ip "sed -i 's/debug_mon * = .*/debug_mon     = $debug_mon/g' /etc/ceph/ceph.conf"
    ssh -T root@$ip "sed -i 's/debug_paxos  * = .*/debug_paxos      = $debug_paxos/g' /etc/ceph/ceph.conf"
    ssh -T root@$ip "sed -i 's/debug_optracker * = .*/debug_optracker = $debug_optracker/g' /etc/ceph/ceph.conf"
    ssh -T root@$ip "sed -i 's/osd_enable_op_tracker * = .*/osd_enable_op_tracker = $osd_enable_op_tracker/g' /etc/ceph/ceph.conf"
    echo -e "Modify:\n    debug_xstore = $debug_xstore\n    debug_osd = $debug_osd\n    debug_mon     = $debug_mon\n    debug_paxos      = $debug_paxos\n    debug_optracker  = $debug_opt_mon     = $debug_mon\n    debug_paxos      = $debug_paxos\n    debug_optracker  = $debug_optracker"

    ssh -T root@$ip "sed -i '/global/a\osd_async_recovery_max_updates = $osd_async_recovery_max_updates' /etc/ceph/ceph.conf"
    ssh -T root@$ip "sed -i '/global/a\osd_op_complaint_time = $osd_op_complaint_time' /etc/ceph/ceph.conf"
    ssh -T root@$ip "sed -i '/global/a\osd_op_tracker_dump_lat = $osd_op_tracker_dump_lat' /etc/ceph/ceph.conf"
    ssh -T root@$ip "sed -i '/global/a\mutex_stall_strace = $mutex_stall_strace' /etc/ceph/ceph.conf"
    ssh -T root@$ip "sed -i '/global/a\mutex_stall_strace_2 = $mutex_stall_strace_2' /etc/ceph/ceph.conf"
    ssh -T root@$ip "sed -i '/global/a\mscache_promote_weight_threshold = $mscache_promote_weight_threshold' /etc/ceph/ceph.conf"
    ssh -T root@$ip "sed -i '/global/a\xstore_mscache_inject_bypass_probability = $xstore_mscache_inject_bypass_probability' /etc/ceph/ceph.conf"

    if [ `grep -c PgRepairEnabled /etc/xms/xms.conf` -eq '0' ];then
        sed -i  '/ceph/a\PgRepairEnabled = false' /etc/xms/xms.conf
        sed -i  '/ceph/a\\' /etc/xms/xms.conf
    else
        sed -i "s/PgRepairEnabled * = .*/PgRepairEnabled = false/g" /etc/xms/xms.conf
    fi
    echo -e "Add:\n    osd_async_recovery_max_updates = $osd_async_recovery_max_updates\n    osd_op_complaint_time = $osd_op_complaint_time\n    osd_op_tracker_dump_lat = $osd_op_tracke_dump_lat\
        \n    mutex_stall_strace = $mutex_stall_strace\n    mutex_stall_strace_2 = $mutex_stall_strace_2\n    mscache_promote_weight_threshold = $mscache_promote_weight_threshold\n    xstore_mscache_inject_bypass_probability = $xstore_mscache_inject_bypass_probability"
done
}

restart_service()
{
for ip in $host
do
    echo $ip
    echo -e "\033[31m  Restart service... \033[0m"
	ssh -T root@$ip "systemctl restart ceph.target"
	ssh -T root@$ip "systemctl restart xmsd.service"
    echo -e "\033[31m  Restart service Complete \033[0m"
	sleep 10
done
}
message()
{
    echo -e "\033[33m You need to provide parameters to the script!!! \033[0m"
    echo -e "\033[31m Optional parameters: \033"
    echo -e "\033[33m ebs \033[0m" "\033[33m Modify the\033[0m"  "\033[31m ebs \033[0m" "\033[33mlogging level. \033[0m"
    echo -e "\033[33m eos \033[0m" "\033[33m Modify the\033[0m"  "\033[31m eos \033[0m" "\033[33mlogging level. \033[0m"
}

set_rgw()
{
for ip in $host
do
    echo -e "\033[31m $ip set debug_rgw \033[0m"
    ssh -T root@$ip "sed -i 's/debug_rgw * = .*/debug_rgw = $rgw\/$rgw/g' /etc/ceph/ceph.conf"
done
}

add_eos(){
for ip in $host
do
    echo -e "\033[31m $ip Began to change \033[0m"
    ssh -T root@$ip "sed -i 's/debug_objclass * = .*/debug_objclass = $obj\/$obj/g' /etc/ceph/ceph.conf"
    ssh -T root@$ip "sed -i '/\[client\]/a\debug_lc = $lc/$lc' /etc/ceph/ceph.conf"
    ssh -T root@$ip "sed -i '/\[client\]/a\debug_bgt = $bgt/$bgt' /etc/ceph/ceph.conf"
    ssh -T root@$ip "sed -i '/\[client\]/a\debug_logtrans = $trans/$trans' /etc/ceph/ceph.conf"
    echo -e "Add:\n     debug_objclass = $obj\/$obj\n     debug_lc = $lc/$lc\n     debug_bgt = $bgt/$bgt\n     debug_logtrans = $trans/$trans"
done
}
modify_eos(){
for ip in $host
do
    echo -e "\033[31m $ip Began to change \033[0m"
    ssh -T root@$ip "sed -i 's/debug_objclass * = .*/debug_objclass = ${obj}\/${obj}/g' /etc/ceph/ceph.conf"
    ssh -T root@$ip "sed -i 's/debug_lc * = .*/debug_lc = ${lc}\/${lc}/g' /etc/ceph/ceph.conf"
    ssh -T root@$ip "sed -i 's/debug_bgt * = .*/debug_bgt = ${bgt}\/${bgt}/g' /etc/ceph/ceph.conf"
    ssh -T root@$ip "sed -i 's/debug_logtrans * = .*/debug_logtrans = ${trans}\/${trans}/g' /etc/ceph/ceph.conf"
    echo -e "Modify:\n     debug_objclass = $obj\/$obj\n     debug_lc = $lc/$lc\n     debug_bgt = $bgt/$bgt\n     debug_logtrans = $trans/$trans"
done
}

###main
if [ $# -lt 1 ];then
    message
    exit 1
fi

arg=$1
parm=$2
case $arg in
    ebs)
        #modify_ebs  ## Modify existing options
        add_ebs ## Modify existing, Add options that do not exist
        restart_service
        echo -e "\033[31m  Modify Complete!!! \033[0m"
        ;;
    
    eos)
        set_rgw ## Set the RGW log level.
        add_eos ## add debug_objclass,debug_lc,debug_bgt,debug_logtrans log level
        #modify_eos  ## Modificationsalready existed(debug_objclass,debug_lc,debug_bgt,debug_logtrans)
        restart_service
        echo -e "\033[31m  Modify Complete!!! \033[0m"
        ;;
    *)
        message
        exit 1
        ;;
esac
