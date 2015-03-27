FROM centos:centos6
MAINTAINER mpg@flaxen.com
ENV TUPLE_OUT=/vagrant/tuple-out

ADD nginx.repo /etc/yum.repos.d/

RUN rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm && yum -y update && yum -y install nginx && rm /etc/nginx/conf.d/default.conf && mkdir /usr/share/nginx/html/rialto && 

ADD nginx.conf /etc/nginx/nginx.conf
ADD rialto-tuple.conf /etc/nginx/conf.d/rialto-tuple.conf
ADD @TODO put tuple-data in server docroot
ADD $TUPLE_OUT /usr/share/nginx/html/rialto/

EXPOSE 80
CMD /usr/sbin/nginx

