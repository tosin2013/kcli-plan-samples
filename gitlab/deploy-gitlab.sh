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

ansiblesafe -f "${ANSIBLE_VAULT_FILE}" -o 2
PASSWORD=$(yq eval '.admin_user_password' "${ANSIBLE_VAULT_FILE}")
VM_NAME=gitlab-server
IMAGE_NAME=Fedora-Cloud-Base-37-1.7.x86_64.qcow2
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
if [ -d $HOME/.generated/vmfiles ]; then
  echo "generated directory already exists"
else
  sudo mkdir -p  $HOME/.generated/vmfiles
  sudo mkdir -p  /root/.generated/vmfiles
fi

sudo python3 profile_generator/profile_generator.py update_yaml gitlab gitlab/template.yaml --image ${IMAGE_NAME} \
--user fedora --user-password ${PASSWORD} --net-name ${NET_NAME} --disk-size ${DISK_SIZE} \
--memory ${MEMORTY} --cpu-num ${CPU_NUM}
sudo echo ${PULL_SECRET} | sudo tee pull-secret.json
cat  kcli-profiles.yml
ansiblesafe -f "${ANSIBLE_VAULT_FILE}" -o 1
sudo cp kcli-profiles.yml ~/.kcli/profiles.yml
sudo cp kcli-profiles.yml /root/.kcli/profiles.yml
sudo rm pull-secret.json
echo "Creating VM ${VM_NAME}"
sudo kcli create vm -p gitlab ${VM_NAME} --wait