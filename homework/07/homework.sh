#!/bin/bash

# ЗАДАНИЕ №1
# 1. Написать сервис, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого # слова. Файл и слово должны задаваться в /etc/sysconfig
# создаем файл с конфигурацией сервиса
# добавляем строки
 echo -e "WORD="ALERT"\nLOG=/var/log/watchlog.log" > /etc/sysconfig/watchlog

# скопируем все необходимые файлы с рабочей машины
cp /vagrant/task1/watchlog.log /var/log/watchlog.log
cp /vagrant/task1/watchlog.sh /opt/watchlog.sh
chmod +x /opt/watchlog.sh
cp /vagrant/task1/watchlog.service /etc/systemd/system/watchlog.service
cp /vagrant/task1/watchlog.timer /etc/systemd/system/watchlog.timer

# стартуем сервис
systemctl daemon-reload
systemctl start watchlog.timer

# проверим вывод
systemctl status watchlog.timer
systemctl status watchlog.service

# ЗАДАНИЕ №2
# 2. Из epel установить spawn-fcgi и переписать init-скрипт на unit-файл.
# Имя сервиса должно так же называться.
# устанавливаем нужные пакеты
yum install epel-release -y && yum install spawn-fcgi php php-cli mod_fcgid httpd -y

# расскоментируем строки
sed -i 's/#SOCKET/SOCKET/' /etc/sysconfig/spawn-fcgi
sed -i 's/#OPTIONS/OPTIONS/' /etc/sysconfig/spawn-fcgi

# скоприуем подготовленный файл
cp /vagrant/task2/spawn-fcgi.service /etc/systemd/system/spawn-fcgi.service

# запускаем и проверяем файл
systemctl start spawn-fcgi
systemctl status spawn-fcgi

# ЗАДАНИЕ №3
# 3. Дополнить юнит-файл apache httpd возможностьб запустить несколько
# инстансов сервера с разными конфигами

# ВЗЯЛ ИЗ ПОДСКАЗОК
# создать unit-файл по шаблону из /etc/systemd/system/httpd.service. ОБЯЗАТЕЛЬНО сделать
# его в виде httpd@.service, иначе не взлетит
cp /usr/lib/systemd/system/httpd.service /etc/systemd/system/httpd@.service
# добавляем для нацеливания на разные конфиги будем использовать опцию %I
sed -i 's/EnvironmentFile=\/etc\/sysconfig\/httpd/EnvironmentFile=\/etc\/sysconfig\/httpd-config-%I/' /etc/systemd/system/httpd@.service

# Для удачного запуска, в конфигурационных файлах должны быть указаны
# уникальные длa каждого экземплaра опции Listen и PidFile.
# Соответственно в директории с конфигами httpd должны лежать два
# конфига, в нашем случае это будут first.conf и second.conf
# создаем два конфигурациооных файла в /etc/httpd/conf
cp /etc/httpd/conf/httpd.conf > /etc/httpd/conf/first.conf
cp /etc/httpd/conf/httpd.conf > /etc/httpd/conf/second.conf

# изменяем строки в каждом файле
sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/first.conf
sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/second.conf

# добавляем строку после строки ServerRoot в каждом файле
sed -i '/ServerRoot "\/etc\/httpd"/a PidFile \/var\/run\/httpd-firs.pid' /etc/httpd/conf/first.conf
sed -i '/ServerRoot "\/etc\/httpd"/a PidFile \/var\/run\/httpd-second.pid' /etc/httpd/conf/second.conf

# переносим оригинал файла httpd
mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.orig

# Включаем окружение в systemd для наших httpd
cp /etc/sysconfig/httpd /etc/sysconfig/httpd-first
cp /etc/sysconfig/httpd /etc/sysconfig/httpd-second

sed -i 's/#OPTIONS=/OPTIONS=-f \/etc\/httpd\/conf\/first.conf/' /etc/sysconfig/httpd-first
sed -i 's/#OPTIONS=/OPTIONS=-f \/etc\/httpd\/conf\/second.conf/' /etc/sysconfig/httpd-second

# снова переносим оригинал файла
mv /etc/sysconfig/httpd /etc/sysconfig/httpd.orig

# Выключаем основной httpd
systemctl disable httpd
systemctl daemon-reload

# запускаем сервисы и проверяем статус
systemctl start httpd@first
sleep 3

systemctl start httpd@second
sleep 3

systemctl status httpd@first
systemctl status httpd@second

