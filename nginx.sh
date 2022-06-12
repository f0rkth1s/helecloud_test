#!/bin/bash

# update repos
sudo yum update -y
# install nginx
sudo amazon-linux-extras install nginx1 -y
# start nginx service
sudo systemctl start nginx