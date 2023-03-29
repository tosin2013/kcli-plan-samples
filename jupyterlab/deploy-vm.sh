#!/bin/bash
set -xe 
if [ -f ../helper_scripts/default.env ];
then 
  source ../helper_scripts/default.env
else
  echo "default.env file does not exist"
  exit 1
fi

cd $KCLI_SAMPLES_DIR

export ANSIBLE_VAULT_FILE="$HOME/quibinode_navigator/inventories/localhost/group_vars/control/vault.yml"
ansiblesafe -f "${ANSIBLE_VAULT_FILE}" -o 2
PASSWORD=$(yq eval '.admin_user_password' "${ANSIBLE_VAULT_FILE}")
NET_NAME=qubinet
VM_NAME=jupyterlab-$(echo $RANDOM | md5sum | head -c 5; echo;)
IMAGE_NAME=Fedora-Cloud-Base-37-1.7.x86_64.qcow2
DISK_SIZE=50
sudo rm -rf kcli-profiles.yml
if [ -f ~/.kcli/profiles.yml ]; then
  sudo cp  ~/.kcli/profiles.yml kcli-profiles.yml
else 
    sudo mkdir -p ~/.kcli
    sudo mkdir -p /root/.kcli
fi
sudo python3 profile_generator/profile_generator.py update_yaml jupyterlab jupyterlab/template.yaml --image ${IMAGE_NAME} --user fedora --user-password ${PASSWORD} --net-name ${NET_NAME}  --disk-size ${DISK_SIZE} 
cat  kcli-profiles.yml
ansiblesafe -f "${ANSIBLE_VAULT_FILE}" -o 1
sudo cp kcli-profiles.yml ~/.kcli/profiles.yml
sudo cp kcli-profiles.yml /root/.kcli/profiles.yml
echo "Creating VM ${VM_NAME}"
sudo kcli create vm -p jupyterlab ${VM_NAME} --wait