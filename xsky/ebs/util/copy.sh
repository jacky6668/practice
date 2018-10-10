while [ 1 ]
do
for i in `cat folderlist`
do
echo "+++++++++++++++  $i  Begin +++++++++++++++++++++++++"
sleep 1
date
umount  /mnt1
mount $i /mnt1
md5sum /mnt1/data.tar
rm -f /mnt1/data.tar
#sync
cp ./data.tar /mnt1
#sync
date
echo "+++++++++++++++  $i  End ++++++++++++++++++++++++++"
done
done
