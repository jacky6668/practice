#!/bin/bash

set -x

echo "1.config logrotate of ganesha"
if [ -f "/etc/logrotate.d/ganesha" ]
then
    echo "ganesh config file exist"
else
    echo "NOT EXIST! now add ganesha's logrotate conf"
    cat  <<EOF > /etc/logrotate.d/ganesha
/export/jcloud-cfs/log/ganesha*.log {
    rotate 60
    size 1G
    compress
    missingok
    notifempty
    copytruncate
}
EOF
fi

echo "2.config cron task of ganesha"
if [ -f "/etc/cron.d/ganesha" ]
then
    echo "ganesh cron task has been setted"
else
    echo "NOT EXIST! now set cron task"
    echo "*/5 * * * * root /usr/sbin/logrotate /etc/logrotate.d/ganesha" > /etc/cron.d/ganesha
fi

cat /etc/logrotate.d/ganesha
cat /etc/cron.d/ganesha
echo "success"

