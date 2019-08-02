FROM  nginx:1.17-alpine
MAINTAINER isblokhin
RUN apk update && apk upgrade 
ADD https://raw.githubusercontent.com/isblokhin/otus-linux/master/homework/10/index.html /usr/share/nginx/html
EXPOSE 80
CMD ["nginx"]
