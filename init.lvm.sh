#!/sbin/sh
LVM_PART='/dev/block/mmcblk0p2'

/lvm/sbin/lvm pvcreate $LVM_PART
/lvm/sbin/lvm vgcreate lvpool $LVM_PART
/lvm/sbin/lvm lvcreate -L 400M -n system lvpool
/lvm/sbin/lvm lvcreate -l 100%FREE -n userdata lvpool

/sbin/make_ext4fs -b 4096 -g 32768 -i 8192 -I 256 -l -16384 -a /system /dev/lvpool/system
/sbin/make_ext4fs -b 4096 -g 32768 -i 8192 -I 256 -l -16384 -a /data /dev/lvpool/userdata
