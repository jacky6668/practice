#!/bin/bash
start_time(){
	for i in {1..10000}    
	do
	    status=`ceph -s|grep recovery|awk -F ":" '{print $1}'`
	    if [[ $status =~ "recovery" ]]
	    then
	        echo  recovery is staring...
		starttime=`date +'%Y-%m-%d %H:%M:%S'`	
	        break
	    else
	        echo  not recovery...
	        continue	    
	    fi
	done
}

end_time(){
	for i in {1..600000}
	do
	    sleep 2
	    status=`ceph -s|grep recovery|awk -F ":" '{print $1}'`
	    if [[ $status =~ "recovery" ]]
	    then
	        echo  recoverying...
		continue
	    else
	        echo  ===========recovery END============
	        endtime=`date +'%Y-%m-%d %H:%M:%S'`
		break
	    fi
	done
}
start_time
end_time
start_seconds=$(date --date="$starttime" +%s);
end_seconds=$(date --date="$endtime" +%s);
result=$((end_seconds-start_seconds))"s"
echo $result
