# установливаем необходимые утилиты
yum install -y redhat-lsb-core wget rpmdevtools rpm-build createrepo yum-utils gcc openssl-

devel

# Загрузим SRPM пакет NGINX длā далþнейшей работý над ним:
wget nginx.org/packages/centos/7/SRPMS/nginx-1.10.0-1.el7.ngx.src.rpm
# устанавливаем пакет
rpm -i nginx-1.14.1-1.el7_4.ngx.src.rpm 

# скачиваем и разархивируем пакет openssl
 wget https://www.openssl.org/source/latest.tar.gz
 tar -xvf latest.tar.gz
# поставим все зависимости чтобý в процессе сборки не бýло ошибок
yum-builddep rpmbuild/SPECS/nginx.spec

# приступаем к сборке RPM пакета
# результат 
Executing(%clean): /bin/sh -e /var/tmp/rpm-tmp.wUGRTg
+ umask 022
+ cd /home/i.blokhin/rpmbuild/BUILD
+ cd nginx-1.14.1
+ /usr/bin/rm -rf /home/i.blokhin/rpmbuild/BUILDROOT/nginx-1.14.1-1.el7_4.ngx.x86_64
+ exit 0

# првоеряем созданнные пакеты
[root@centos7 ~]#  ll rpmbuild/RPMS/x86_64/
total 3076
-rw-r--r--. 1 root root  770116 May 30 11:44 nginx-1.14.1-1.el7_4.ngx.x86_64.rpm
-rw-r--r--. 1 root root 2375024 May 30 11:44 nginx-debuginfo-1.14.1-1.el7_4.ngx.x86_64.rpm


# делаем установку из собранного пакета 
 yum localinstall -y rpmbuild/RPMS/x86_64/nginx-1.14.1-1.el7_4.ngx.x86_64.rpm

# стартуем сервис и проверяем статус
 systemctl start nginx
  systemctl status nginx

 nginx.service - nginx - high performance web server
   Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; vendor preset: disabled)
   Active: active (running) since Thu 2019-05-30 13:35:19 UTC; 7s ago

# создаем каталог для repo

mkdir /usr/share/nginx/html/repo

# копируем туда наш собраннýй RPM
cp nginx-1.14.1-1.el7_4.ngx.x86_64.rpm /usr/share/nginx/html/repo/
wget http://www.percona.com/downloads/percona-release/redhat/0.1-6/percona-release-0.1-6.noa

# инициализируем репозиторий
createrepo /usr/share/nginx/html/repo/


Spawning worker 0 with 1 pkgs
Spawning worker 1 with 1 pkgs
Workers Finished
Saving Primary metadata
Saving file lists metadata
Saving other metadata
Generating sqlite DBs
Sqlite DBs complete

# проверāем синтаксис и перезапускаем nginx
# резулþтате location будет вýглāдетþ так:
# location / {
# root /usr/share/nginx/html;
# index index.html index.htm;
# autoindex on; #Добавили эту директиву
# }

nginx -t
nginx -s reload
# проверяем репозиторий curl -a http://localhost/repo/
root@centos7  …/rpmbuild/RPMS/x86_64   curl -a http://localhost/repo/                     ✘ 

 15:27:05
<html>
<head><title>Index of /repo/</title></head>
<body bgcolor="white">
<h1>Index of /repo/</h1><hr><pre><a href="../">../</a>
<a href="repodata/">repodata/</a>                                          30-May-2019 15:24    

               -
<a href="nginx-1.14.1-1.el7_4.ngx.x86_64.rpm">nginx-1.14.1-1.el7_4.ngx.x86_64.rpm</a>           

     30-May-2019 15:19              770144
<a href="percona-release-0.1-6.noarch.rpm">percona-release-0.1-6.noarch.rpm</a>                 

  13-Jun-2018 06:34               14520
</pre><hr></body>
</html>


# добавляем htgjpbnjhbq 
root@centos7 cat >> /etc/yum.repos.d/otus.repo << EOF
[otus]
name=otus-linux
baseurl=http://localhost/repo
gpgcheck=0
enabled=1
EOF
# Убедимсā что репозиторий подклĀчилсā и посмотрим что в нем есть:
yum repolist enabled | grep otusyum list | grep otus

#n ак как NGINX у нас уже стоит установим репозиторий percona-release:
root@centos7 yum install percona-release -y


