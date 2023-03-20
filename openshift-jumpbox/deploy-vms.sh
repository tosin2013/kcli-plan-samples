#!/bin/bash
set -xe 
cd /opt/qubinode-installer/kcli-plan-samples/

export ANSIBLE_VAULT_FILE="$HOME/quibinode_navigator/inventories/localhost/group_vars/control/vault.yml"
ansiblesafe -f "${ANSIBLE_VAULT_FILE}" -o 2
PASSWORD=$(yq eval '.admin_user_password' "${ANSIBLE_VAULT_FILE}")
OFFLINE_TOKEN=$(yq eval '.offline_token' "${ANSIBLE_VAULT_FILE}")
PULL_SECRET=$(yq eval '.openshift_pull_secret' "${ANSIBLE_VAULT_FILE}")
NET_NAME=qubinet
VM_NAME=openshift-jumpbox-$(echo $RANDOM | md5sum | head -c 5; echo;)
IMAGE_NAME=Fedora-Cloud-Base-37-1.7.x86_64.qcow2
sudo rm -rf kcli-profiles.yml
sudo cp ~/.kcli/profiles.yml kcli-profiles.yml
sudo python3 profile_generator/profile_generator.py update_yaml ${VM_NAME} openshift-jumpbox/template.yaml --image ${IMAGE_NAME} --user $USER --user-password ${PASSWORD} --net-name ${NET_NAME}  --offline-token ${OFFLINE_TOKEN}  --pull-secret ${PULL_SECRET}
cat  kcli-profiles.yml
ansiblesafe -f "${ANSIBLE_VAULT_FILE}" -o 1
#sudo cp kcli-profiles.yml ~/.kcli/profiles.yml
#sudo cp kcli-profiles.yml /root/.kcli/profiles.yml
