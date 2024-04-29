#!/bin/bash

yum update -y 
yum install httpd
systemctl start httpd
systemctl enable httpd

echo "hello world, my name is long from $(hostname -f)" > /var/www/html/index.html # copy paragraph to index.html file