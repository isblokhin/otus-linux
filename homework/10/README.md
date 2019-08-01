### Создайте свой кастомный образ nginx на базе alpine. После запуска nginx должен
### отдавать кастомную страницу (достаточно изменить дефолтную страницу nginx)

скачиваем образ nginx
```
docker pull nginx
```
запускаем nginx
```
docker run -d -p 8080:80 --name nginx-otus nginx
```
проверяем работоспособность сервера
```
 curl http://localhost:8080
```


