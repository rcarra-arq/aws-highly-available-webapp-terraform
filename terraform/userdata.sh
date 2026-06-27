#!/bin/bash

dnf update -y
dnf install nginx -y

systemctl enable nginx
systemctl start nginx

echo "<h1>Terraform AWS HA WebApp</h1>" > /usr/share/nginx/html/index.html

echo "ok" > /usr/share/nginx/html/health
