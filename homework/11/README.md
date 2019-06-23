### 1. Запретить всем пользователям, кроме группы admin логин в выходные и праздничные дни

Взял за основу метод проверки от коллеги в слаке для проверки праздничных дней:
https://habr.com/ru/post/405519/

Создаем 2 пользователя
```
- adminuser1
- fakeuser1
``` 
и 2 группы
```
- admin
- fakeadmin
```
Проверка текущего дня проходит с помощью скрипта ### [script_pam](https://github.com/isblokhin/otus-linux/blob/master/homework/11/script_pam.sh)
Заменяем файл /etc/sshd на новый, в котором добавлен модуль ### [sshd](https://github.com/isblokhin/otus-linux/blob/master/homework/11/sshd)


