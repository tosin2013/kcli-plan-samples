#!/bin/bash
# https://www.redhat.com/sysadmin/install-jupyterlab-linux
DEFAULT_PASSWORD='CHANGEME'
sudo dnf update -y 
sudo dnf install git vim unzip wget tar python3 python3-pip util-linux-user tmux firewalld -y 
sudo python3 -m pip install --user --upgrade pip
python3 -m pip install --user jupyterlab
sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo firewall-cmd --add-port=8888/tcp --permanent
sudo firewall-cmd --reload
jupyter-lab --no-browser --ip=0.0.0.0 --port=8888 --NotebookApp.password='${DEFAULT_PASSWORD}'
