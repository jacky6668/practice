#!/bin/bash

##################################
#This script can init some os config
#1.add hosts
#2.set hostname
#3.stop && disable firewalld
#4.set se config disable
#5.create sshkey and copy
#################################


#1.add hosts
add_hosts()
{
cat >> /etc/hosts <<EOF
EOF
}

#2.set hostname
set_hostname()
{
hostnamectl set-hostname XXX
}


#3.stop && disable firewalld
firewall()
{
systemctl stop firewalld.service
systemctl disable firewalld.service
}

#4.set se config disable
se()
{
sed -i 's/enforcing/disabled/g' /etc/selinux/config
}

ssh()
{
echo ""
}

network()
{
cat >> /etc/sysconfig/network-scripts/ifcfg-em3 <<EOF
DNS1=114.114.114.114
EOF
systemctl restart network.service
sleep 5 
yum install -y vim
yum install -y git
yum install -y expect
yum install -y screen 
}

#main
network
add_hosts
set_hostname
firewall
se
#ssh
reboot
