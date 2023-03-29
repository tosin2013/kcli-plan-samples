#!/bin/bash
# https://www.redhat.com/sysadmin/install-jupyterlab-linux
sudo dnf update -y 
dnf install git vim unzip wget tar python3 python3-pip util-linux-user tmux  -y 
sudo python3 -m pip install --user --upgrade pip
python3 -m pip install --user jupyterlab
jupyter-lab --no-browser –-port=8888

sudo firewall-cmd --add-service http --permanent
 sudo firewall-cmd –reload