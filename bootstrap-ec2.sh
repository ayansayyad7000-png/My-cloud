#!/bin/bash

apt update -y
apt install apache2 -y

systemctl enable apache2
systemctl start apache2
