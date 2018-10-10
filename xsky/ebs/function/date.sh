
for i in {1..1000000};
do
    date -s 10:22:22
    sleep 60
    ntpdate cn.pool.ntp.org
    sleep 60
done
