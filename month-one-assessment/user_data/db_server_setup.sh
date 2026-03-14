#!/bin/bash

yum update -y
yum install postgresql-server -y

postgresql-setup initdb

systemctl start postgresql
systemctl enable postgresql
