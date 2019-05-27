# помещаем данный скрипт в /etc/cron.hourly для выполнения ежечасно
# либо в crontab -e 0 * * * * /root/parser.sh




#!/bin/bash

# c помощью find ищем файлик nginx.log
 logfile=$(find / | grep nginx.log)
# получаем последнюю строку, которая была час назад, записываем её в переменную
 var1=$(cat previous-data.txt)

# переходим в рабочую директорию
 cd /root


# считаем максимальное ко-во запросов с момента последнего запуска для 10 ip адресов
tail -n +$var1 $logfile |awk '{print $1}' |sort |uniq -c |sort -rn| head > ipcount.txt
#считаем  кол-во запрашиваемых адресов с момента последнего запуска
tail -n +$var1 $logfile |awk '{print $7}' |sort |uniq -c |sort -rn| head > ipcount2.txt
# считаем кол-во ошибок
tail -n +$var1 $logfile |awk '{print $9}' |grep -E "[4-5]{1}[0-9][[:digit:]]" |sort |uniq -c |sort -rn > ercount.txt
#считаем список кодов возвратов с их общим числом
tail -n +$var1 $logfile |awk '{print $9}' |sort |uniq -c |sort -rn > codcount.txt

# считаем количество строк в файле, чтобы через час пропустить нужное количество строк и записываем его в файлик.
  wc -l /root/nginx.log | awk '{print $1}' > previous-data.txt

 ipcount=$(cat ipcount.txt)
 ipcount2=$(cat ipcount2.txt)
 ercount=$(cat ercount.txt)
 codcount=$(cat codcount.txt)

# отправка сообщения после завершения скрипта
trap "echo "Count of ip: $ipcount, \n $ipcount2; \n count of errors: $ercount, \n count of cods: $codcount \n" | sendmail -s "Report on homework4" alert@example.com"" EXIT
