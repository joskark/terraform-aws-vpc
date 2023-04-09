#!/bin/bash
dnf install docker -y
usermod -a -G docker ec2-user
newgrp docker
systemctl start docker
systemctl enable docker

docker pull nginx:latest
docker run --name mynginx -p 80:80 -d nginx