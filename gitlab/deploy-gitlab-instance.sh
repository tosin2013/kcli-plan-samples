#!/bin/bash 

sudo apt update -y
sudo apt install git vim unzip wget tar python3 python3-pip tmux ansible-core -y
sudo rm -rf /var/lib/apt/lists/partial/*
sudo apt-get update
sudo apt-get clean

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

# Check if the ansible user already exists before creating it
if id "ansible" >/dev/null 2>&1; then
    echo "ansible user already exists"
else
    # Create Ansible user and set password
    sudo useradd ansible
    sudo usermod -aG sudo ansible
    sudo passwd ansible
    sudo mkdir /home/ansible

    # Set ownership of ansible home directory
    sudo chown -R ansible:ansible /home/ansible

    # Set up SSH key for Ansible user
    ssh-keygen -f ~/.ssh/id_rsa -t rsa -N ''
    ssh-copy-id ansible@${IP_ADDRESS}
    echo "${IP_ADDRESS} ${DOMAIN_NAME}" | sudo tee -a /etc/hosts
fi

sudo ansible-playbook -i hosts playbook.yml  -e @playbook_vars.yml

sudo  gitlab-rake "gitlab:password:reset[root]"
