#!/bin/bash

pgcheck()
{
ceph osd getmap -o /tmp/osdmap
osdmaptool /tmp/osdmap --check-pg-upmaps > /tmp/result
num=`grep ERR /tmp/result`
if [[ $num -ne 0 ]]
then
    echo "there is pg place wrong"
    exit 1
else
    echo "pg stat is ok"
fi
}

rep2()
{
echo "This is 2 replicated pool"
osd=`xms-cli --user admin -p admin -f '{{range .}}{{print .id ","}}{{end}}' osd list`
#echo $osd 
osd=${osd%?}
#echo $osd 
xms-cli --user admin -p admin pool create --pool-type "replicated" -r block -s 2 --osds $osd pool 1>/dev/null

for i in {1..100000}
do
    stat=`xms-cli --user admin -p admin -f '{{range .}}{{print .status}}{{end}}' pool list`
    if [[ $stat =~ "active" ]]
    then
        #echo "pool create stat is $stat"
        break
    else
        sleep 2
        continue
    fi
done

pgcheck

pool=`xms-cli --user admin -p admin -f '{{range .}}{{print .id}}{{end}}' pool list`
xms-cli --user admin -p admin pool delete $pool 1>/dev/null
for i in {1..100000}
do
    stat=`xms-cli --user admin -p admin -f '{{range .}}{{print .status}}{{end}}' pool list`
    if [[ $stat == "deleting" ]]
    then
        #echo "pool delete stat is $stat"
        sleep 2
        continue
    else
        break
    fi
done
echo "~~~~~~~~~~~~~~~~~~~~~~~~~"
}

rep3()
{
echo "This is 3 replicated pool"
osd=`xms-cli --user admin -p admin -f '{{range .}}{{print .id ","}}{{end}}' osd list`
#echo $osd 
osd=${osd%?}
#echo $osd 
xms-cli --user admin -p admin pool create --pool-type "replicated" -r block -s 2 --osds $osd pool 1>/dev/null

for i in {1..100000}
do
    stat=`xms-cli --user admin -p admin -f '{{range .}}{{print .status}}{{end}}' pool list`
    if [[ $stat =~ "active" ]]
    then
        #echo "pool create stat is $stat"
        break
    else
        sleep 2
        continue
    fi
done

pgcheck

pool=`xms-cli --user admin -p admin -f '{{range .}}{{print .id}}{{end}}' pool list`
xms-cli --user admin -p admin pool delete $pool 1>/dev/null
for i in {1..100000}
do
    stat=`xms-cli --user admin -p admin -f '{{range .}}{{print .status}}{{end}}' pool list`
    if [[ $stat == "deleting" ]]
    then
        #echo "pool delete stat is $stat"
        sleep 2
        continue
    else
        break
    fi
done
echo "~~~~~~~~~~~~~~~~~~~~~~~~~"
}

ec21()
{
echo "This is 2+1 ec pool"
osd=`xms-cli --user admin -p admin -f '{{range .}}{{print .id ","}}{{end}}' osd list`
#echo $osd 
osd=${osd%?}
#echo $osd 
xms-cli --user admin -p admin pool create --pool-type "erasure" -r block -k 2 -m 1 --osds $osd pool 1>/dev/null

for i in {1..100000}
do
    stat=`xms-cli --user admin -p admin -f '{{range .}}{{print .status}}{{end}}' pool list`
    if [[ $stat =~ "active" ]]
    then
        #echo "pool create stat is $stat"
        break
    else
        sleep 2
        continue
    fi
done

pgcheck

pool=`xms-cli --user admin -p admin -f '{{range .}}{{print .id}}{{end}}' pool list`
xms-cli --user admin -p admin pool delete $pool 1>/dev/null
for i in {1..100000}
do
    stat=`xms-cli --user admin -p admin -f '{{range .}}{{print .status}}{{end}}' pool list`
    if [[ $stat == "deleting" ]]
    then
        #echo "pool delete stat is $stat"
        sleep 2
        continue
    else
        break
    fi
done
echo "~~~~~~~~~~~~~~~~~~~~~~~~~"
}

#main
for i in {1..1}
do
    rep2
    rep3
    ec21
done
