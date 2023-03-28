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
VM_NAME=miniChRIS-podman-$(echo $RANDOM | md5sum | head -c 5; echo;)
IMAGE_NAME=ubuntu-22.04-server-cloudimg-amd64.img
DISK_SIZE=160
MEMORTY=16384
CPU_NUM=4
sudo rm -rf kcli-profiles.yml
if [ -f ~/.kcli/profiles.yml ]; then
  sudo cp  ~/.kcli/profiles.yml kcli-profiles.yml
else 
    sudo mkdir -p ~/.kcli
    sudo mkdir -p /root/.kcli
fi
sudo python3 profile_generator/profile_generator.py update_yaml miniChRIS-podman-ubuntu miniChRIS-podman-ubuntu/template.yaml \
--image ${IMAGE_NAME} --user ubuntu --user-password ${PASSWORD} \
--net-name ${NET_NAME}  --disk-size ${DISK_SIZE}  \
--memory ${MEMORTY} --numcpus ${CPU_NUM}
cat  kcli-profiles.yml
ansiblesafe -f "${ANSIBLE_VAULT_FILE}" -o 1
sudo cp kcli-profiles.yml ~/.kcli/profiles.yml
sudo cp kcli-profiles.yml /root/.kcli/profiles.yml
echo "Creating VM ${VM_NAME}"
sudo kcli create vm -p miniChRIS-podman-ubuntu ${VM_NAME} --wait