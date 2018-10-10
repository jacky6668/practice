#!/bin/bash

XDCD="xdcd"
XDCADM="xdcadm"

delete_iscsi_np() {
	nps=`ls $1/np/`
	for np in $nps
	do
		echo "delete iscsi net port $np"
		rmdir $1/np/$np > /dev/null 2>&1
		RETVAL=$?
    		if [ "$RETVAL" -ne 0 ] ; then
        		echo "delete iscsi net port $np failed, please check."
        		exit 1
    		fi
	done
}

delete_iscsi_acl_luns() {
	acl_luns=`ls $1 |grep lun`
	for acl_lun in $acl_luns
	do
		link=`find $1/$acl_lun/ -type l`
		echo "delete iscsi acl lun link $link"              
		unlink $link > /dev/null 2>&1
		RETVAL=$?
		if [ "$RETVAL" -ne 0 ] ; then
				echo "delete iscsi acl lun link $link failed, please check."
				exit 1
		fi

		echo "delete iscsi acl lun $acl_lun"
		rmdir $1/$acl_lun > /dev/null 2>&1
		RETVAL=$?
		if [ "$RETVAL" -ne 0 ] ; then
				echo "delete iscsi acl lun $acl_lun failed, please check."
				exit 1
		fi
	done
}

delete_iscsi_acls() {
	acls=`ls $1/acls/`
	for acl in $acls
	do
		echo "delete iscsi acs luns"
		delete_iscsi_acl_luns $1/acls/$acl

		echo "delete iscsi acl $acl"
		rmdir $1/acls/$acl > /dev/null 2>&1
		RETVAL=$?
		if [ "$RETVAL" -ne 0 ] ; then
				echo "delete iscsi acl $acl failed, please check."
				exit 1
		fi      
	done
}

delete_iscsi_luns() {
	luns=`ls $1/lun/`
	for lun in $luns
	do
		link=`find $1/lun/$lun/ -type l`
		echo "delete iscsi lun link $link"		
		unlink $link > /dev/null 2>&1
		RETVAL=$?
		if [ "$RETVAL" -ne 0 ] ; then
				echo "delete iscsi lun link $link failed, please check."
				exit 1
		fi

		echo "delete iscsi lun $lun"
		rmdir $1/lun/$lun > /dev/null 2>&1
		RETVAL=$?
		if [ "$RETVAL" -ne 0 ] ; then
				echo "delete iscsi lun $lun failed, please check."
				exit 1
		fi
	done
}

delete_iscsi_target() {
	if [ -d /sys/kernel/config/target/iscsi ]; then
		targets=`ls /sys/kernel/config/target/iscsi/ |grep iqn`
		for target in $targets
		do
			echo "delete iscsi /sys/kernel/config/target/iscsi/$target/tpgt_1 nps, acls and luns."
			delete_iscsi_np /sys/kernel/config/target/iscsi/$target/tpgt_1
			delete_iscsi_acls /sys/kernel/config/target/iscsi/$target/tpgt_1
			delete_iscsi_luns /sys/kernel/config/target/iscsi/$target/tpgt_1
			
			echo "disable iscsi target $target"
                        echo 0 >/sys/kernel/config/target/iscsi/$target/tpgt_1/enable
			
			echo "delete iscsi target $target"
			rmdir /sys/kernel/config/target/iscsi/$target/tpgt_1
			rmdir /sys/kernel/config/target/iscsi/$target > /dev/null 2>&1
			RETVAL=$?
			if [ "$RETVAL" -ne 0 ] ; then
					echo "delete iscsi target $target failed, please check."
					exit 1
			fi
		done
	fi
	
	echo "delete iscsi mode"
	if [ -d /sys/kernel/config/target/iscsi ]; then
		rmdir /sys/kernel/config/target/iscsi > /dev/null 2>&1
		RETVAL=$?
		if [ "$RETVAL" -ne 0 ] ; then
			echo "delete iscsi mode failed, please check."
			exit 1
		fi
	fi
}

delete_fc_acl_luns() {
	acl_luns=`ls $1 |grep lun`
	for acl_lun in $acl_luns
	do
		link=`find $1/$acl_lun/ -type l`
		echo "delete fc acl lun link $link"              
		unlink $link > /dev/null 2>&1
		RETVAL=$?
		if [ "$RETVAL" -ne 0 ] ; then
				echo "delete fc acl lun link $link failed, please check."
				exit 1
		fi

		echo "delete fc acl lun $acl_lun"
		rmdir $1/$acl_lun > /dev/null 2>&1
		RETVAL=$?
		if [ "$RETVAL" -ne 0 ] ; then
				echo "delete fc acl lun $acl_lun failed, please check."
				exit 1
		fi
	done
}

delete_fc_acls() {
	acls=`ls $1/acls/`
	for acl in $acls
	do
		echo "delete fc acls luns"
		delete_fc_acl_luns $1/acls/$acl

		echo "delete fc acl $acl"
		rmdir $1/acls/$acl > /dev/null 2>&1
		RETVAL=$?
		if [ "$RETVAL" -ne 0 ] ; then
				echo "delete fc acl $acl failed, please check."
				exit 1
		fi      
	done
}

delete_fc_luns() {
	luns=`ls $1/lun/`
	for lun in $luns
	do
		link=`find $1/lun/$lun/ -type l`
		echo "delete fc lun link $link"		
		unlink $link > /dev/null 2>&1
		RETVAL=$?
		if [ "$RETVAL" -ne 0 ] ; then
				echo "delete fc lun link $link failed, please check."
				exit 1
		fi
	
		echo "delete fc lun $lun"
		rmdir $1/lun/$lun > /dev/null 2>&1
		RETVAL=$?
		if [ "$RETVAL" -ne 0 ] ; then
				echo "delete fc lun $lun failed, please check."
				exit 1
		fi
	done
}

delete_fc_target() {
	if [ -d /sys/kernel/config/target/qla2xxx ]; then
		targets=`cat /sys/class/fc_host/host*/port_name | sed -e s/0x// -e 's/../&:/g' -e s/:$//`
		for target in $targets
		do
			echo "delete fc /sys/kernel/config/target/qla2xxx/$target/tpgt_1 acls and luns."
			delete_fc_acls /sys/kernel/config/target/qla2xxx/$target/tpgt_1
			delete_fc_luns /sys/kernel/config/target/qla2xxx/$target/tpgt_1
			
			echo "disable fc target $target"
                        echo 0 >/sys/kernel/config/target/qla2xxx/$target/tpgt_1/enable
			
			echo "delete fc target $target"
			rmdir /sys/kernel/config/target/qla2xxx/$target/tpgt_1
			rmdir /sys/kernel/config/target/qla2xxx/$target > /dev/null 2>&1
			RETVAL=$?
			if [ "$RETVAL" -ne 0 ] ; then
					echo "delete fc target $target failed, please check."
					exit 1
			fi
		done
	fi
	
	echo "delete fc mode"
	if [ -d /sys/kernel/config/target/qla2xxx ]; then
		rmdir /sys/kernel/config/target/qla2xxx > /dev/null 2>&1
		RETVAL=$?
		if [ "$RETVAL" -ne 0 ] ; then
			echo "delete fc mode failed, please check."
				exit 1
		fi
	fi
}

delete_local_luns() {
	luns=`ls $1/lun/`
	for lun in $luns
	do
		link=`find $1/lun/$lun/ -type l`
		echo "delete local lun link $link"		
		unlink $link > /dev/null 2>&1
		RETVAL=$?
		if [ "$RETVAL" -ne 0 ] ; then
				echo "delete local lun link $link failed, please check."
				exit 1
		fi
	
		echo "delete local lun $lun"
		rmdir $1/lun/$lun > /dev/null 2>&1
		RETVAL=$?
		if [ "$RETVAL" -ne 0 ] ; then
				echo "delete local lun $lun failed, please check."
				exit 1
		fi
	done
}

delete_local_target() {
	if [ -d /sys/kernel/config/target/loopback ]; then
		targets=`ls /sys/kernel/config/target/loopback/ |grep iqn`
		for target in $targets
		do
			echo "delete local /sys/kernel/config/target/loopback/$target/tpgt_1 acls and luns."
			delete_local_luns /sys/kernel/config/target/loopback/$target/tpgt_1
			
			echo "delete local target $target"
			rmdir /sys/kernel/config/target/loopback/$target/tpgt_1
			rmdir /sys/kernel/config/target/loopback/$target > /dev/null 2>&1
			RETVAL=$?
			if [ "$RETVAL" -ne 0 ] ; then
					echo "delete local target $target failed, please check."
					exit 1
			fi
		done
	fi
	
	echo "delete local mode"
	if [ -d /sys/kernel/config/target/loopback ]; then
		rmdir /sys/kernel/config/target/loopback > /dev/null 2>&1
		RETVAL=$?
		if [ "$RETVAL" -ne 0 ] ; then
			echo "delete local mode failed, please check."
			exit 1
		fi
	fi
}

delete_core_user() {
	users=`ls /sys/kernel/config/target/core/ |grep user`
	for user in $users
	do
		volume=`ls /sys/kernel/config/target/core/$user/ |grep volume`

		echo "delete core user $volume"
		rmdir /sys/kernel/config/target/core/$user/$volume > /dev/null 2>&1
		RETVAL=$?
		if [ "$RETVAL" -ne 0 ] ; then
				echo "delete core user $volume failed, please check."
				exit 1
		fi		

		rmdir /sys/kernel/config/target/core/$user > /dev/null 2>&1
		RETVAL=$?
		if [ "$RETVAL" -ne 0 ] ; then
				echo "delete core user $user failed, please check."
				exit 1
		fi
	done
}

delete_iscsi_target
delete_fc_target
delete_local_target
delete_core_user
