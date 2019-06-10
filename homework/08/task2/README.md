2. Задание:
Установить систему с LVM, после чего переименовать VG

Посмотрим текущее состояние:
```
[root@lvm ~]# vgs
  VG         #PV #LV #SN Attr   VSize   VFree
  VolGroup00   1   2   0 wz--n- <38.97g    0
```

Переименуем группу
```
[root@lvm ~]# vgrename VolGroup00 OtusRoot
  Volume group "VolGroup00" successfully renamed to "OtusRoot"
```
Делаем резервные копии

```
[root@lvm ~]# cp -f /etc/fstab /etc/fstab.backup
[root@lvm ~]# cp -f /etc/default/grub /etc/default/grub.backup
[root@lvm ~]# cp -f /boot/grub2/grub.cfg /boot/grub2/grub.cfg.backup
```
Меняем название группы на новое в файлах:
```
[root@lvm ~]# sed -i "s/VolGroup00/OtusRoot/g" /etc/fstab
[root@lvm ~]# sed -i "s/VolGroup00/OtusRoot/g" /etc/default/grub
[root@lvm ~]# sed -i "s/VolGroup00/OtusRoot/g" /boot/grub2/grub.cfg
```

Пересоздаем initrd image, чтобы он знал новое название Volume Group
```
[root@lvm ~]# mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
*** Creating initramfs image file '/boot/initramfs-3.10.0-862.2.3.el7.x86_64.img' done ***
```

Перезагружаемся и проверяем название группы:
```
[root@lvm vagrant]# vgs
  VG       #PV #LV #SN Attr   VSize   VFree
  OtusRoot   1   2   0 wz--n- <38.97g    0
```
