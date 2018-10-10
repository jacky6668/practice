#!/usr/bin/env python
import os
import subprocess 
import paramiko

#create ip.list file ip list 

vdbench_home="/root/vdbench/"
threads=32
general="data_error=500,validate=yes,validate=read_after_write,validate=no_preread,validate=time\n"
wd="wd=wd1,sd=sd*,seekpct=100,rdpct=0,xfersize=(4k,50,4M,50)\n"
rd="rd=rd1,wd=wd1,iorate=max,elapse=604800000,interval=1,warmup=1\n"
cont=[]
hds=[]
port=22
username="root"
password="redhat"
sd_num=1
node=["10.252.2.136"]

cont.append(general)
hd="hd=default,vdbench={0},user=root,shell=ssh\n".format(vdbench_home)
cont.append(hd)

#f=open("ip.list")
for host in node:
    hd = host.split('.')[-1]
    system=("hd=hd{0},system={1}\n").format(hd.strip('\n'),host.strip('\n'))
    cont.append(system)
    hds.append(hd)

#file=open("ip.list")
for hostname in node:
    hd = hostname.split('.')[-1]
    #s = paramiko.SSHClient() 
    #s.set_missing_host_key_policy(paramiko.AutoAddPolicy()) 
    #s.connect(hostname, port, username, password)
    #stdin,stdout,sterr = s.exec_command("ls -l /dev/disk/by-path/  |grep node198 |awk -F'/' '{print $NF}'") 
    #stdin,stdout,sterr = s.exec_command("ls /dev/mapper/ |grep mpath |awk -F'-' '{print $1}'") 
    luns = os.popen("ls /dev/mapper/ |grep mpath |awk -F'-' '{print $1}'").readlines()
    #luns = stdout.readlines()
    for lun in luns:
        #sd="sd=sd{0},hd=hd{1},lun=/dev/{2},threads={3},openflags=o_direct,size=100G\n".format(sd_num,hd.strip('\n'),lun.strip('\n'),threads)
        sd="sd=sd{0},hd=hd{1},lun=/dev/mapper/{2},threads={3},openflags=o_direct,size=100G\n".format(sd_num,hd.strip('\n'),lun.strip('\n'),threads)
        cont.append(sd) 
    	sd_num=sd_num+1
    #s.close() 

cont.append(wd)
cont.append(rd)

with open(r"yibo","w+") as f:
    for line in cont:
        f.write(line)
print "vdbench script path:"+os.getcwd()+"/yibo"

