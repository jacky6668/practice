#!/bin/sh

for((i=1;i<=1000;i++));
do
  echo "==========================================="
  echo "create local at $i times..."
  xdcadm --lld at --mode at --op create --atid 2 --servernode node198 --boardid 0
  xdcadm --lld at --mode target --op create --atid 2 --iqn iqn.2018-05.node198.2.1ad2ba008e1082cf --type local
  xdcadm --lld at --mode lun --op create --lunname volume-afafc7f0c7e448e3919149eb63ed6978 --lunsn 1983c03ef9940cce --lunsize 10737418240 --luncfg ceph/pool-196a89f9e7f8492e8847e0a505d9b5af/volume-afafc7f0c7e448e3919149eb63ed6978
  xdcadm --lld at --mode lun --op add --atid 2 --lunname volume-afafc7f0c7e448e3919149eb63ed6978 --lunid 0
  echo "sleep 30s for local scsi..."
  xdcadm -L at -m at -o show
  sleep 30

  echo "==========================================="
  echo "delete local at $i times..."
  xdcadm --lld at --mode lun --op remove --atid 2 --lunname volume-afafc7f0c7e448e3919149eb63ed6978 --lunid 0
  xdcadm --lld at --mode lun --op delete --lunname volume-afafc7f0c7e448e3919149eb63ed6978
  xdcadm --lld at --mode target --op delete --atid 2 --iqn iqn.2018-05.node198.2.1ad2ba008e1082cf
  xdcadm --lld at --mode at --op delete --atid 2
  echo "sleep 10s for local scsi..."
  xdcadm -L at -m at -o show
  sleep 10
  echo "==========================================="
done 
