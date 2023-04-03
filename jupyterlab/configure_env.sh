#!/bin/bash
# https://www.redhat.com/sysadmin/install-jupyterlab-linux
DEFAULT_PASSWORD='CHANGEME'
sudo dnf update -y 
sudo dnf install git vim unzip wget tar python3 python3-pip util-linux-user tmux firewalld -y 
sudo dnf install ncurses-devel curl -y
curl 'https://vim-bootstrap.com/generate.vim' --data 'editor=vim&langs=javascript&langs=go&langs=html&langs=ruby&langs=python' > ~/.vimrc
sudo python3 -m pip install --user --upgrade pip
python3 -m pip install --user jupyterlab
sudo systemctl enable firewalld
sudo systemctl start firewalld
sudo firewall-cmd --add-port=8888/tcp --permanent
sudo firewall-cmd --reload
jupyter notebook --generate-config
jupyter-lab --no-browser --ip=0.0.0.0 --port=8888 --NotebookApp.password=$DEFAULT_PASSWORD
