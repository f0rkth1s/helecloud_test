#!/bin/bash
# sleep until instance is ready
until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 10
done
# install nginx
#yum -y upgrade
#yum -y install nginx1
amazon-linux-extras install nginx1 -y
# make sure nginx is started
service nginx start