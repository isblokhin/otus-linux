#!/bin/bash

# зануляю суперблоки
mdadm --zero-superblock --force /dev/sd{b..e}
# создаю раид5 из 4 дисков
mdadm -C -v /dev/md0 -l 5 -n 4 /dev/sd{b..e}
# создаю gpt раздел на raid
parted -s /dev/md0 mklabel gpt
# создаю 5 партиций
parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkprat primary ext4 40% 60%
parted /dev/md0 mkpart primary ext4 60% 80%
parted /dev/md0 mkpart primary ext4 80% 100%
# создаю файловую систему на партициях
for i in $(seq 1 5); do mkfs.ext4 /dev/md0p$i; done
# создаю каталоги для монтирования
mkdir -p /raid/part{1..5}
# монтирую в созданные каталоги 5 партиций
for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done#!/bin/bash

# зануляю суперблоки
mdadm --zero-superblock --force /dev/sd{b..e}
# создаю раид5 из 4 дисков
mdadm -C -v /dev/md0 -l 5 -n 4 /dev/sd{b..e}
# создаю gpt раздел на raid
parted -s /dev/md0 mklabel gpt
# создаю 5 партиций
parted /dev/md0 mkpart primary ext4 0% 20%
parted /dev/md0 mkpart primary ext4 20% 40%
parted /dev/md0 mkpart primary ext4 40% 60%
parted /dev/md0 mkpart primary ext4 60% 80%
parted /dev/md0 mkpart primary ext4 80% 100%
# создаю файловую систему на партициях
for i in $(seq 1 5); do mkfs.ext4 /dev/md0p$i; done
# создаю каталоги для монтирования
mkdir -p /raid/part{1..5}
# монтирую в созданные каталоги 5 партиций
for i in $(seq 1 5); do mount /dev/md0p$i /raid/part$i; done


