
# 1. Написать сервис, который будет раз в 30 секунд мониторить лог на предмет наличия ключевого # слова. Файл и слово должны задаваться в /etc/sysconfig
# создаем файл с конфигурацией сервиса
nano /etc/sysconfig/watchlog

# добавляем строки
 WORD="ALERT"
 LOG=/var/log/watchlog.log

# создаем файл и пишем туда любые строки, плюс ключевое слово 'ALERT'
nano /var/log/watchlog.log

# создаем сам скрипт
#!/bin/bash
WORD=$1
LOG=$2
DATE=`date`
if grep $WORD $LOG &> /dev/null
then
logger "$DATE: I found word, Master!"
else
exit 0
fi

# cоздадим юнит для сервиса:
[root@centos system]# nano watchlog.service

[Unit]
Description=My watchlog service
[Service]
Type=oneshot
EnvironmentFile=/etc/sysconfig/watchdog
ExecStart=/opt/watchlog.sh $WORD $LOG

# cоздадим юнит для таймера:
[root@centos system]# nano watchlog.timer

[Unit]
Description=Run watchlog script every 30 second
[Timer]
# Run every 30 second
OnUnitActiveSec=30
Unit=watchlog.service
[Install]
WantedBy=multi-user.target

# стартуем сервис
[root@centos system]# systemctl start watchlog.timer

# проверяем результат
[root@centos system]# tail -f /var/log/messages
Jun  5 13:46:38 centos systemd: Started Session 301 of user vagrant.
Jun  5 13:46:38 centos systemd-logind: New session 301 of user vagrant.
Jun  5 13:49:17 centos chronyd[1280]: Source 80.240.216.155 replaced with 91.207.136.55
Jun  5 13:49:23 centos su: (to root) vagrant on pts/0
Jun  5 13:52:00 centos yum[4400]: Installed: nano-2.3.1-10.el7.x86_64
Jun  5 14:01:03 centos systemd: Created slice User Slice of root.
Jun  5 14:01:03 centos systemd: Started Session 302 of user root.
Jun  5 14:01:05 centos systemd: Removed slice User Slice of root.
Jun  5 14:33:09 centos chronyd[1280]: Source 37.193.156.169 replaced with 85.21.78.91
Jun  5 14:53:47 centos systemd: Started Run watchlog script every 30 second.


# 2. Из epel установить spawn-fcgi и переписать init-скрипт на unit-файл. Имя сервиса должно # так же называться.**


# устанавливаем spawn-fcgi и необходимые пакеты:
[root@centos ~]#  yum install epel-release -y && yum install spawn-fcgi php php-cli mod_fcgid httpd -y

# etc/rc.d/init.d/spawn-fcg - cам Init скрипт, который будем переписывать, Но перед yтим # необходимо раскомментироват? строки с переменными в/etc/sysconfig/spawn-fcgi (строки с #переменными SOCKET=..., OPTIONs=...)

[root@centos system]# cat /etc/sysconfig/spawn-fcgi
# You must set some working options before the "spawn-fcgi" service will work.
# If SOCKET points to a file, then this file is cleaned up by the init script.
#
# See spawn-fcgi(1) for all possible options.
#
# Example :
SOCKET=/var/run/php-fcgi.sock
OPTIONS="-u apache -g apache -s $SOCKET -S -M 0600 -C 32 -F 1 -P /var/run/spawn-fcgi.pid -- /usr/bin/php-cgi"

# создаем файл сервиса
[root@centos system]# nano /etc/systemd/system/spawn-fcgi.service
[root@centos system]# cat /etc/systemd/system/spawn-fcgi.service
[Unit]
Description=Spawn-fcgi startup service by Otus
After=network.target
[Service]
Type=simple
PIDFile=/var/run/spawn-fcgi.pid
EnvironmentFile=/etc/sysconfig/spawn-fcgi
ExecStart=/usr/bin/spawn-fcgi -n $OPTIONS
KillMode=process
[Install]
WantedBy=multi-user.target

# проверяем работу службы 
[root@centos system]# systemctl start spawn-fcgi
[root@centos system]# systemctl status spawn-fcgi
? spawn-fcgi.service - Spawn-fcgi startup service by Otus
   Loaded: loaded (/etc/systemd/system/spawn-fcgi.service; disabled; vendor preset: disabled)
   Active: active (running) since Wed 2019-06-05 15:15:28 UTC; 7min ago
 Main PID: 4682 (php-cgi)
    Tasks: 33
   Memory: 12.7M



# 3. Дополнить юнит-файл apache httpd возможностью запустить несколько инстансов сервера с # разными конфигами**


# ВЗЯЛ ИЗ ПОДСКАЗОК
# создать unit-файл по шаблону из /etc/systemd/system/httpd.service. ОБЯЗАТЕЛЬНО сделать # его в виде httpd@.service, иначе не взлетит
[root@centos system]# cp usr/lib/systemd/system/httpd.service /etc/systemd/system/httpd@.service


[root@centos system]# nano /etc/systemd/system/httpd@.service

# добавляем в строку EnvironmentFile=/etc/sysconfig/httpd-  "%I"
[root@centos conf]# cat /etc/systemd/system/httpd@.service
[Unit]
Description=The Apache HTTP Server multiconfig
After=network.target remote-fs.target nss-lookup.target
Documentation=man:httpd(8)
Documentation=man:apachectl(8)
[Service]
Type=notify
EnvironmentFile=/etc/sysconfig/httpd-%I
ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
ExecStop=/bin/kill -WINCH ${MAINPID}
KillSignal=SIGCONT
PrivateTmp=true
[Install]
WantedBy=multi-user.target


# Для удачного запуска, в конфигурационных файлах должны быть указаны
# уникальные длa каждого экземплaра опции Listen и PidFile. 
# Соответственно в директории с конфигами httpd должны лежать два
# конфига, в нашем случае это будут first.conf и second.conf
# создаем два конфигурациооных файла в /etc/httpd/conf
[root@centos system]# cat /etc/httpd/conf/httpd.conf > /etc/httpd/conf/first.conf
[root@centos system]# cat /etc/httpd/conf/httpd.conf > /etc/httpd/conf/second.conf

# изменяем строки в каждом файле
[root@centos system]# sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/first.conf
[root@centos system]# sed -i 's/Listen 80/Listen 8080/' /etc/httpd/conf/second.conf

# добавляем строку после строки ServerRoot в каждом файле
[root@centos system]# sed -i '/ServerRoot "\/etc\/httpd"/a PidFile \/var\/run\/httpd-firs.pid' /etc/httpd/conf/first.conf

[root@centos system]# sed -i '/ServerRoot "\/etc\/httpd"/a PidFile \/var\/run\/httpd-second.pid' /etc/httpd/conf/secondt.conf

# переносим оригинал файла httpd
[root@centos system]# mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.orig

# Включаем окружение в systemd для наших httpd
[root@centos system]# cp /etc/sysconfig/httpd /etc/sysconfig/httpd-first
[root@centos system]# cp /etc/sysconfig/httpd /etc/sysconfig/httpd-second

[root@centos system]# sed -i 's/#OPTIONS=/OPTIONS=-f \/etc\/httpd\/conf\/first.conf/' /etc/sysconfig/httpd-first
[root@centos system]# sed -i 's/#OPTIONS=/OPTIONS=-f \/etc\/httpd\/conf\/second.conf/' /etc/sysconfig/httpd-second

# снова переносим оригинал файла
[root@centos system]# mv /etc/sysconfig/httpd /etc/sysconfig/httpd.orig

# Выключаем основной httpd
[root@centos system]# systemctl disable httpd
[root@centos system]# systemctl daemon-reload
# запускаем первый сервис и проверяем статус
[root@centos sysconfig]# systemctl start httpd@first
[root@centos sysconfig]# systemctl status httpd@first
? httpd@first.service - The Apache HTTP Server multiconfig
   Loaded: loaded (/etc/systemd/system/httpd@.service; disabled; vendor preset: disabled)
   Active: active (running) since Fri 2019-06-07 05:59:57 UTC; 7s ago
     Docs: man:httpd(8)
           man:apachectl(8)
 Main PID: 6680 (httpd)


# запускаем второй сервис и проверяем статус
[root@centos conf]# systemctl start httpd@second
[root@centos conf]# systemctl status httpd@second
? httpd@second.service - The Apache HTTP Server multiconfig
   Loaded: loaded (/etc/systemd/system/httpd@.service; disabled; vendor preset: disabled)
   Active: active (running) since Fri 2019-06-07 06:04:46 UTC; 9s ago
     Docs: man:httpd(8)
           man:apachectl(8)


