3. Добавить модуль в initrd


# Создаем папку для нашего моду и копируем скрипты в эту папку 
mkdir /usr/lib/dracut/modules.d/01test
cp /vagrant/task3/module_setup.sh /usr/lib/dracut/modules.d/01test/module-setup.sh
chmod +x /usr/lib/dracut/modules.d/01test/module-setup.sh
cp /vagrant/task3/test.sh /usr/lib/dracut/modules.d/01test/test.sh
chmod +x /usr/lib/dracut/modules.d/01test/test.sh
# Обновим образ initrd
# можно выполнить
# 1.  mkinitrd -f -v /boot/initramfs-$(uname -r).img $(uname -r)
# 2. dracut -f -v
dracut -f -v 
# проверим загрузился ли наш модуль 
lsinitrd -m /boot/initramfs-$(uname -r).img | grep test

# после чего можно проверить двумя путями
# Перезагрузитmсяи руками выключить опции rghb и quiet и увидеть вывод
# Либо отредактировать grub.cfg убрав эти опции
# В итоге при загрузке будет пауза на 10 секунд и вы увидите пингвина в выводе 

