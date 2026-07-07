#!/bin/bash
# 更新系统 + 装 nginx + 起服务 / update packages, install nginx, start the service
dnf update -y
dnf install -y nginx
systemctl enable nginx
systemctl start nginx

# 写一个测试页面，证明 user_data 真的跑过了
# write a test page to prove user_data actually executed
echo "<h1>Hello from Terraform user_data! 你好，来自 user_data 的问候！</h1>" > /usr/share/nginx/html/index.html