#!/bin/bash 
# https://github.com/jjaswanson4/device-edge-workshops/tree/main/provisioner#lab-setup

pip3 install jmespath
cd /opt/device-edge-workshops/provisioner
URL=http://192.168.1.240/manifest_tower-dev_20230325T132029Z.zip
curl -s -o manifest.zip $URL
cd ..

sed -i 's\your-workshop-domain.lcl\qubinodelab.io\g' local-inventory.yml
sed -i "s|192.168.200.10|$(hostname -I)|g" local-inventory.yml

ansible-galaxy  install -r execution-environment/requirements.yml
sed -i '16d' provisioner/workshop_vars/rhde_aw_120.yml
cat provisioner/workshop_vars/rhde_aw_120.yml | grep groups
ansible-playbook  provisioner/provision_lab.yml -e @extra_vars.yml -i local-inventory.yml
