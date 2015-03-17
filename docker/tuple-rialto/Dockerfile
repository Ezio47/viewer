FROM centos:centos6

MAINTAINER mpg@flaxen.com

ADD nginx.repo /etc/yum.repos.d/

RUN rpm -Uvh http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarc.rpm && yum -y update && yum -y install nginx 

ADD nginx.conf /etc/nginx/nginx.conf
ADD rialto-tuple.conf /etc/nginx/conf.d/rialto-tuple.conf

# @TODO This needs to be an actual path to the rialto docroot
ADD TUPLEDOCROOT /usr/share/nginx/html/rialto/

EXPOSE 80
CMD /usr/sbin/nginx

