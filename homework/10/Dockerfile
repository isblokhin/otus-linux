FROM nginx:alpine
MAINTAINER isblokhin
RUN apt update -y && apt upgrade -y 
ADD https://raw.githubusercontent.com/isblokhin/otus-linux/master/homework/10/index.html /usr/share/nginx/html
EXPOSE 80
CMD ["nginx"]
