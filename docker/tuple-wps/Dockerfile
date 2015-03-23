# OSSIM container
#
# Version 0.0.1
 
# Base centos/centos6
FROM centos:centos6
 
MAINTAINER Kit Plummer kitplummer@gmail.com
ADD ossim.repo /etc/yum.repos.d/
 
#RUN yum update -y
RUN yum repolist
RUN yum install -y ossim
 
# Output
# ENTRYPOINT tail /var/log/yum.log

