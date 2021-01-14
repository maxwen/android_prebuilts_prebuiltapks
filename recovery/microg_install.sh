#!/sbin/sh

if [ ! -f "/tmp/microg.zip" ]; then
    echo "/tmp/microg.zip not found" >> /tmp/microg_install.log
    exit 1
fi

if [ -b "/dev/block/mmcblk0" ]; then
    DEVICE=mmcblk0
    PARTITION=p2
else
    DEVICE=sda
    PARTITION=2
fi

mount -t ext4 /dev/block/$DEVICE$PARTITION /system_root 1>> /tmp/microg_install.log 2>&1
EXIT=$?
if [ $EXIT != "0" ]; then
    echo $EXIT >> /tmp/microg_install.log
    exit $EXIT
fi
unzip /tmp/microg.zip -o -d /system_root/ 1>> /tmp/microg_install.log 2>&1
EXIT=$?
if [ $EXIT != "0" ]; then
    echo $EXIT >> /tmp/microg_install.log
    exit $EXIT
fi

# now we must change ro.build.date to trigger a pm rescan
# we simply append -microg cause we know this is a simple
# string equals and nobody will evaluate if it is really a date
if [ ! -f "/system_root/system/build.prop" ]; then
    echo "/system_root/system/build.prop not found" >> /tmp/microg_install.log
    exit 1
fi

cp /system_root/system/build.prop /tmp/
grep 'ro.build.date=' /tmp//build.prop >> /tmp/microg_install.log 2>&1
#awk '{ if ($0 ~ /^ro.build.date=.*/) {print $0 "-microg"} else {print $0}}' /tmp/build.prop > /system_root/system/build.prop
sed -E 's/((ro\.build\.date\=)(.*)([0-9]+))$/\1-microg/g' /system_root/system/build.prop
grep 'ro.build.date=' /system_root/system/build.prop >> /tmp/microg_install.log 2>&1
exit 0
