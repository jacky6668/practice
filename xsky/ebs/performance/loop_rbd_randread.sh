#!/bin/bash

while true; do fio -direct=1 -iodepth=128 -thread -rw=randread -ioengine=rbd -bssplit=4k/20:8K/20:16K/20:64k/20:128k/10:512k/10 -group_reporting -name=asdf -numjobs=16 -clientname=admin -pool=pool-986b9113579b4038a741284cf62ece66 -rbdname=volume-36cc83b8cd32428880260fd25b48dbb2; done
