#!/bin/bash

et -ex

user_name="XXXX"
pass_word="YYYY"

# 密钥对不存在则创建密钥
[ ! -f /root/.ssh/id_rsa.pub ] && ssh-keygen -t rsa -p '' &>/dev/null
while read line;do
    ip=`echo $line | cut -d " " -f1`
    #user_name=`echo $line | cut -d " " -f2`
    #pass_word=`echo $line | cut -d " " -f3`
expect <<EOF
    spawn ssh-copy-id -i /root/.ssh/id_rsa.pub $user_name@$ip
    expect {
        "yes/no" { send "yes\n";exp_continue}
        "password" { send "$pass_word\n"}
    }
    expect eof
EOF
done < node.txt
