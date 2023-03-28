#!/bin/bash 

sudo apt update -y
sudo apt install git vim unzip wget tar python3 python3-pip tmux ansible-core -y

sudo ansible-galaxy install geerlingguy.gitlab
IP_ADDRESS=$(hostname -I | awk '{print $1}')
DOMAIN_NAME=github.testnet.io
# Create ansible hosts file
cat >hosts<<EOF
[servers]
${IP_ADDRESS}   ansible_user=ansible 
EOF

cat >playbook.yml<<EOF
- hosts: localhost
  connection: local 
  roles:
    -  geerlingguy.gitlab
EOF

sudo useradd ansible
sudo usermod -aG sudo ansible
sudo passwd ansible
sudo chown -R ansible:ansible /home/ansible

ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''
ssh-copy-id ansible@${IP_ADDRESS}
echo "${IP_ADDRESS} ${DOMAIN_NAME}" | sudo tee -a /etc/hosts

sudo ansible-playbook -i hosts playbook.yml  -e @playbook_vars.yml

sudo  gitlab-rake "gitlab:password:reset[root]"
