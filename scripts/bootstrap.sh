#!/bin/bash

# update repos
sudo yum update -y
# install nginx
sudo amazon-linux-extras install nginx1 -y
# create mount point
sudo mkdir -p /mnt/efs
# mount the efs volume
sudo mount -t nfs4 -o nfsvers=4.1 ${aws_efs_mount_target.fe-efs-mt.dns_name}:/ /mnt/efs
# create fstab entry
#sudo su -c \"echo ${aws_efs_mount_target.fe-efs-mt.dns_name}:/ /mnt/efs nfs defaults,vers=4.1 0 0 >> /etc/fstab\"
sudo echo ${aws_efs_mount_target.fe-efs-mt.dns_name}:/ /mnt/efs nfs defaults,vers=4.1 0 0 >> /etc/fstab
# start nginx service
sudo systemctl start nginx
