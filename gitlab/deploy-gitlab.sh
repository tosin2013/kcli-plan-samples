#!/bin/bash
set -xe 
if [ -f ../helper_scripts/default.env ];
then 
  source ../helper_scripts/default.env
else
  echo "default.env file does not exist"
  exit 1
fi

if [ -f  ~/quibinode_navigator/ansible_vault_setup.sh ]; then
   sudo ~/quibinode_navigator/ansible_vault_setup.sh
else
  echo "ansible_vault_setup.sh file does not exist"
  exit 1
fi

cd $KCLI_SAMPLES_DIR

ansiblesafe -f "${ANSIBLE_VAULT_FILE}" -o 2
PASSWORD=$(yq eval '.admin_user_password' "${ANSIBLE_VAULT_FILE}")
VM_NAME=gitlab-server
IMAGE_NAME=ubuntu-22.04-server-cloudimg-amd64.img
DISK_SIZE=160
MEMORTY=16384
CPU_NUM=4
DOMAIN_NAME=$(yq eval '.domain' "${ANSIBLE_ALL_VARIABLES}")
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
--user ansible --user-password ${PASSWORD} --net-name ${NET_NAME} --disk-size ${DISK_SIZE} \
--memory ${MEMORTY} --numcpus ${CPU_NUM}
sudo echo ${PULL_SECRET} | sudo tee pull-secret.json
cat  kcli-profiles.yml
ansiblesafe -f "${ANSIBLE_VAULT_FILE}" -o 1
sudo cp kcli-profiles.yml ~/.kcli/profiles.yml
sudo cp kcli-profiles.yml /root/.kcli/profiles.yml
sudo cp $(pwd)/gitlab/playbook_vars.yml $(pwd)/gitlab/playbook_vars.yml.bak
sudo cp $(pwd)/gitlab/deploy-gitlab-instance.sh $(pwd)/gitlab/deploy-gitlab-instance.sh.bak
sed -i "s/gitlab.testnet.io/gitlab.${DOMAIN_NAME}/g" $(pwd)/gitlab/playbook_vars.yml
sed -i "s/gitlub.testnet.io/gitlab.${DOMAIN_NAME}/g" $(pwd)/gitlab/deploy-gitlab-instance.sh
sudo cp $(pwd)/gitlab/playbook_vars.yml /root/.generated/vmfiles
sudo cp $(pwd)/gitlab/deploy-gitlab-instance.sh /root/.generated/vmfiles
sudo mv $(pwd)/gitlab/playbook_vars.yml.bak $(pwd)/gitlab/playbook_vars.yml
sudo mv $(pwd)/gitlab/deploy-gitlab-instance.sh.bak $(pwd)/gitlab/deploy-gitlab-instance.sh
echo "Creating VM ${VM_NAME}"
sudo kcli create vm -p gitlab ${VM_NAME} --wait