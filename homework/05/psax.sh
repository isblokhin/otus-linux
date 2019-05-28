#!/bin/bash
#1) написать свою реализацию ps ax используя анализ /proc
#- Результат ДЗ - рабочий скрипт который можно запустить


# этого я не знал, подсказали в слак и взял источник отсюда
# https://github.com/shaadowsky/LinuxAdmin012019/blob/master/hw05.%20Processes/psax_2nd_try.sh
proc_uptime=$(cat /proc/uptime | awk -F" " '{print $1}')
# Запросим тактовую частоту планировщика
clk_tck=$(getconf CLK_TCK)


# находим все пиды процессов, для каждого получаем tty, stat, time, command

for i in $(ls -l /proc | awk '{print $9}' | grep "^[0-9]*[0-9]$"| sort -n );
do


tty=$(cat /proc/$i/stat | awk '{print $7}')
stat=$(cat /proc/$i/stat | awk '{print $3}')
utime=$(cat /proc/$i/stat | awk '{print $14}')
stime=$(cat  /proc/$i/stat | awk '{print $17}')
command=$(cat /proc/$i/cmdline | awk '{print $0}')



# получаем time
ttime=$((utime + stime))
time=$((ttime / clk_tck))


# выводим все параметры

printf "   %s\t" $i
printf "   %s\t" $tty
printf "   %s\t" $stat
printf "   %s\t" $time
printf "   %s\n" $command

done

