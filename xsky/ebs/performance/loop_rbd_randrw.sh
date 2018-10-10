#!/bin/bash

while true; do fio -direct=1 -iodepth=128 -thread -rw=randrw -ioengine=rbd -bssplit=4k/20:8K/20:16K/20:64k/20:128k/10:512k/10 -group_reporting -name=asdf -numjobs=16 -clientname=admin -pool=pool-24a7f8b768214e319202c6bb2de0f9de -rbdname=volume-volume-1dfa595008bc4c579ad0be2a7fb23a3c; done
