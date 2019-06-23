#!/bin/bash


# проверяем состоит ли юзер в группе админов
if [[ `grep "admin.*$(echo $PAM_USER)" /etc/group` ]]
then
    exit 0
fi


# получаем текущую дату, удаляем тире и пробелы между данными, чтобы сделать 
# запрос на сайт и записываем в переменную

pam_date=`echo $(date +%Y-%m-%d) | awk -F- '{print $1,$2,$3}' | tr -d ' '`
echo $pam_date
# делаем запрос на сайт из статьи с харба https://habr.com/ru/post/405519/
pam_result=`curl https://isdayoff.ru/$pam_date`
echo $pam_result

if [[ $pam_result==1 ]];
then  
    exit 1
else
    exit 0
fi
