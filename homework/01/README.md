№устанавливаю утилиту для скачавани
yum install -y wget
#скачиваю ядро из ветки stable
wget cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.0.9.tar.xz
#устанавливаю необходимые утилиты для сборки ядра
yum groupinstall "Development Tools"
#разархивирую архив
tar -xvf linux-5.0.9.tar.xz
Долго искал файл config* в директории /boot)))
после долгих, мучительных поисков понял, что в /usr/src
cp linux-5.0.9 /usr/src
cp /usr/src/kernels/3.10.0-957.10.1.el7,x86_64/.config /usr/src/linux-5.0.9
#доустанавливаю необходимые пакеты
yum install ncurses-devel openssl-devel 
make menuconfig
yum install elfutils-libelf-devel
#начинаю процесс сборки
make && make modules

