# создаю pv для 2 дисков
[root@lvm vagrant]# pvcreate /dev/sd{d,e}
  Physical volume "/dev/sdd" successfully created.
  Physical volume "/dev/sde" successfully created.

#Создаю vg для каталога var
[root@lvm vagrant]# vgcreate vg0 /dev/sd{d,e}
  Volume group "vg0" successfully created

#Создаю lv для каталога var
[root@lvm vagrant]# lvcreate -L 900M -m1 -n mirror vg0
  Logical volume "mirror" created.
[root@lvm vagrant]# vgdisplay
  --- Volume group ---
  VG Name               VolGroup00
  System ID
  Format                lvm2
  Metadata Areas        1
  Metadata Sequence No  3
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                2
  Open LV               2
  Max PV                0
  Cur PV                1
  Act PV                1
  VG Size               <38.97 GiB
  PE Size               32.00 MiB
  Total PE              1247
  Alloc PE / Size       1247 / <38.97 GiB
  Free  PE / Size       0 / 0
  VG UUID               SA8LTU-F2yz-FEV1-RdgT-hw0Z-iRxh-yHFKuU

  --- Volume group ---
  VG Name               vg0
  System ID
  Format                lvm2
  Metadata Areas        2
  Metadata Sequence No  3
  VG Access             read/write
  VG Status             resizable
  MAX LV                0
  Cur LV                1
  Open LV               0
  Max PV                0
  Cur PV                2
  Act PV                2
  VG Size               1.99 GiB
  PE Size               4.00 MiB
  Total PE              510
  Alloc PE / Size       452 / <1.77 GiB
  Free  PE / Size       58 / 232.00 MiB
  VG UUID               XbVhOS-rfRn-qVcy-XvBV-s3Y6-MVzS-Aebh5p



[root@lvm vagrant]# mount /dev/vg0/mirror /mnt
[root@lvm vagrant]# cp -R /var/* /mnt/ # rsync -avHPSAX /var/ /mnt/

[root@lvm vagrant]# mkfs.ext4 /dev/vg0/mirror
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
57600 inodes, 230400 blocks
11520 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=236978176
8 block groups
32768 blocks per group, 32768 fragments per group
7200 inodes per group
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376

Allocating group tables: done
Writing inode tables: done
Creating journal (4096 blocks): done
Writing superblocks and filesystem accounting information: done

# копируем все из каталога var
root@lvm vagrant]# cp -R /var/* /mnt/ 
[root@lvm vagrant]# cd /tmp
# создаем дополнительный каталог на случай фиаско и переносим туда /var
[root@lvm tmp]# mkdir var
[root@lvm tmp]# mv -R /var/* /tmp/var/
[root@lvm mnt]# mkfs.ext4 /dev/vg1/snap
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
524288 inodes, 2096128 blocks
104806 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=2147483648
64 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632

Allocating group tables: done
Writing inode tables: done
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done




# отмонтирум /mnt и подмотируем lvm в /var
[root@lvm var]# umount /mnt
[root@lvm var]# mount /dev/vg0/mirror /var
# добалвяю в fstab монтирование
[root@lvm etc]# echo "UUID="4370e14d-de8e-4e47-9b12-f6e5b8334c72" /var ext4 defaults 0 0" >> /mnt/log








# создаем раздел для хоум
[root@lvm mnt]# pvcreate /dev/sdb
vg  Physical volume "/dev/sdb" successfully created.
[root@lvm mnt]# vgcreate vg1 /dev/sdb
  Volume group "vg1" successfully created
[root@lvm mnt]# lvcreate -l+80%FREE -n snap /dev/vg1
WARNING: ext4 signature detected on /dev/vg1/snap at offset 1080. Wipe it? [y/n]: y
  Wiping ext4 signature on /dev/vg1/snap.
  Logical volume "snap" created.

[root@lvm mnt]# mkfs.ext4 /dev/vg1/snap
mke2fs 1.42.9 (28-Dec-2013)
Filesystem label=
OS type: Linux
Block size=4096 (log=2)
Fragment size=4096 (log=2)
Stride=0 blocks, Stripe width=0 blocks
524288 inodes, 2096128 blocks
104806 blocks (5.00%) reserved for the super user
First data block=0
Maximum filesystem blocks=2147483648
64 block groups
32768 blocks per group, 32768 fragments per group
8192 inodes per group
Superblock backups stored on blocks:
        32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632

Allocating group tables: done
Writing inode tables: done
Creating journal (32768 blocks): done
Writing superblocks and filesystem accounting information: done

# монтируем новый раздел, переносив в него var, на случай фиаско переносим в tmp, размонтируем новый раздел и мотируем в home
[root@lvm mnt]# mount /dev/vg1/snap /mnt
[root@lvm mnt]# cp -r /home/* /mnt/
[root@lvm mnt]# mv /tmp/home
mv: missing destination file operand after ‘/tmp/home’
Try 'mv --help' for more information.
[root@lvm mnt]# mv /home/* /tmp/home/
[root@lvm mnt]# umount /mnt
[root@lvm mnt]# mount /dev/vg1/snap /home



# создаем несколько файлов
[root@lvm home]# touch testfile{1..20}
[root@lvm home]# ls
log         testfile11  testfile14  testfile17  testfile2   testfile4  testfile7
testfile1   testfile12  testfile15  testfile18  testfile20  testfile5  testfile8
testfile10  testfile13  testfile16  testfile19  testfile3   testfile6  testfile9
[root@lvm home]#  dd if=/dev/zero of=/home/test.log bs=512M count=1 status=progress
536870912 bytes (537 MB) copied, 65.075878 s, 8.2 MB/s
1+0 records in
1+0 records out
536870912 bytes (537 MB) copied, 65.1469 s, 8.2 MB/s


# создаем снапшот системы
[root@lvm home]# lvcreate -L 1G -s -n home_snap /dev/vg1/snap
  Logical volume "home_snap" created.

# удаляем файлы
[root@lvm home]# rm -f testfile{1..12} log
[root@lvm home]# ll
total 0
-rw-r--r--. 1 root root 0 May 16 19:10 testfile13
-rw-r--r--. 1 root root 0 May 16 19:10 testfile14
-rw-r--r--. 1 root root 0 May 16 19:10 testfile15
-rw-r--r--. 1 root root 0 May 16 19:10 testfile16
-rw-r--r--. 1 root root 0 May 16 19:10 testfile17
-rw-r--r--. 1 root root 0 May 16 19:10 testfile18
-rw-r--r--. 1 root root 0 May 16 19:10 testfile19
-rw-r--r--. 1 root root 0 May 16 19:10 testfile20

# восстанавливаем данные
[root@lvm mnt]# lvconvert --merge /dev/vg1/home_snap
  Merging of volume vg1/home_snap started.
  vg1/snap: Merged: 100.00%
[root@lvm ~]# mount /dev/vg1/snap /home

[root@lvm home]# ls
log         testfile11  testfile14  testfile17  testfile2   testfile4  testfile7
testfile1   testfile12  testfile15  testfile18  testfile20  testfile5  testfile8
testfile10  testfile13  testfile16  testfile19  testfile3   testfile6  testfile9


# создаем точку монтирования для home
[root@lvm etc]# echo " UUID="de449ab5-6d10-45eb-9753-a1c3217cfec2" /home ext4 defaults 0 0" >> /etc/fstab











# создаем раздел и фс на нем
[root@lvm vagrant]#  vgcreate vg0 /dev/sdb
  Physical volume "/dev/sdb" successfully created.
  Volume group "vg0" successfully created
[root@lvm vagrant]# lvcreate -n lv_root -l +100%FREE /dev/vg0
  Logical volume "lv_root" created.
[root@lvm vagrant]# mkfs.xfs /dev/vg0/lv_root
meta-data=/dev/vg0/lv_root       isize=512    agcount=4, agsize=655104 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0, sparse=0
data     =                       bsize=4096   blocks=2620416, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal log           bsize=4096   blocks=2560, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0

# коприуем даныне из корневого каталога в примонтированный
[root@lvm vagrant]# xfsdump -J /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt
[root@lvm ~]# xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt
xfsdump: using file dump (drive_simple) strategy
xfsdump: version 3.1.7 (dump format 3.0)
xfsrestore: using file dump (drive_simple) strategy
xfsrestore: version 3.1.7 (dump format 3.0)
xfsdump: level 0 dump of lvm:/
xfsdump: dump date: Fri May 17 13:20:31 2019
xfsdump: session id: 451bbd89-e3ab-4986-b8ad-86aeda8a9f72
xfsdump: session label: ""
xfsrestore: searching media for dump
xfsdump: ino map phase 1: constructing initial dump list
xfsdump: ino map phase 2: skipping (no pruning necessary)
xfsdump: ino map phase 3: skipping (only one dump stream)
xfsdump: ino map construction complete
xfsdump: estimated dump size: 800800640 bytes
xfsdump: creating dump session media file 0 (media 0, file 0)
xfsdump: dumping ino map
xfsdump: dumping directories
xfsrestore: examining media file 0
xfsrestore: dump description:
xfsrestore: hostname: lvm
xfsrestore: mount point: /
xfsrestore: volume: /dev/mapper/VolGroup00-LogVol00
xfsrestore: session time: Fri May 17 13:20:31 2019
xfsrestore: level: 0
xfsrestore: session label: ""
xfsrestore: media label: ""
xfsrestore: file system id: b60e9498-0baa-4d9f-90aa-069048217fee
xfsrestore: session id: 451bbd89-e3ab-4986-b8ad-86aeda8a9f72
xfsrestore: media id: eeca65b0-b724-4a4b-aaab-09736983d090
xfsrestore: searching media for directory dump
xfsrestore: reading directories
xfsdump: dumping non-directory files
xfsrestore: 3133 directories and 26895 entries processed
xfsrestore: directory post-processing
xfsrestore: restoring non-directory files
xfsdump: ending media file
xfsdump: media file size 772981160 bytes
xfsdump: dump size (non-dir files) : 757832248 bytes
xfsdump: dump complete: 139 seconds elapsed
xfsdump: Dump Status: SUCCESS
xfsrestore: restore complete: 142 seconds elapsed
xfsrestore: Restore Status: SUCCESS

# иммитируем каталог /root и переконфигурируем grub
[root@lvm ~]#  for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
[root@lvm ~]# chroot /mnt/
[root@lvm /]#  grub2-mkconfig -o /boot/grub2/grub.cfg
Generating grub configuration file ...
Found linux image: /boot/vmlinuz-3.10.0-862.2.3.el7.x86_64
Found initrd image: /boot/initramfs-3.10.0-862.2.3.el7.x86_64.img
done
# обновляем образ 
[root@lvm /]# cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g;s/.img//g"` --force; done


# Удаляем lvm и создаем новый
[root@lvm vagrant]# lvremove /dev/VolGroup00/LogVol00
[root@lvm vagrant]# lvcreate -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00
 mkfs.xfs /dev/VolGroup00/LogVol00

# монируем lvm
[root@lvm ~]# mount /dev/VolGroup00/LogVol00 /mnt

# переносим данные
[root@lvm ~]# xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt

# длеаем тоже, что ив предыдущих шагах
[root@lvm ~]# for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
[root@lvm ~]# chroot /mnt/
[root@lvm ~]# grub2-mkconfig -o /boot/grub2/grub.cfg

[root@lvm ~]# cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g;
s/.img//g"` --force; done


