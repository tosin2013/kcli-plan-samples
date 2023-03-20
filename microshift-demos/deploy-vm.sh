#!/bin/bash
set -xe 
cd /opt/qubinode-installer/kcli-plan-samples/

export ANSIBLE_VAULT_FILE="$HOME/quibinode_navigator/inventories/localhost/group_vars/control/vault.yml"
ansiblesafe -f "${ANSIBLE_VAULT_FILE}" -o 2
PASSWORD=$(yq eval '.admin_user_password' "${ANSIBLE_VAULT_FILE}")
OFFLINE_TOKEN=$(yq eval '.offline_token' "${ANSIBLE_VAULT_FILE}")
PULL_SECRET=$(yq eval '.openshift_pull_secret' "${ANSIBLE_VAULT_FILE}")
NET_NAME=qubinet
VM_NAME=microshift-demos-vm
IMAGE_NAME=rhel-baseos-9.1-x86_64-kvm.qcow2
DISK_SIZE=200
sudo rm -rf kcli-profiles.yml
if [ -f ~/.kcli/profiles.yml ]; then
  sudo cp  ~/.kcli/profiles.yml kcli-profiles.yml
else 
    sudo mkdir -p ~/.kcli
    sudo mkdir -p /root/.kcli
fi
sudo python3 profile_generator/profile_generator.py update_yaml microshift-demos microshift-demos/template.yaml \
  --image ${IMAGE_NAME} --user $USER --user-password ${PASSWORD} --net-name ${NET_NAME}  --offline-token ${OFFLINE_TOKEN}  \
  kcs--pull-secret ${PULL_SECRET} --disk-size ${DISK_SIZE}  --rhnactivationkey ${RHSM_ACTIVATION_KEY} --rhnorg ${RHSM_ORG}
cat  kcli-profiles.yml
ansiblesafe -f "${ANSIBLE_VAULT_FILE}" -o 1
sudo cp kcli-profiles.yml ~/.kcli/profiles.yml
sudo cp kcli-profiles.yml /root/.kcli/profiles.yml
echo "Creating VM ${VM_NAME}"
sudo kcli create vm -p microshift-demos ${VM_NAME} --wait