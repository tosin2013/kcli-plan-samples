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

function deploy_via_kcli(){
    export ANSIBLE_VAULT_FILE="$HOME/quibinode_navigator/inventories/localhost/group_vars/control/vault.yml"
    ansiblesafe -f "${ANSIBLE_VAULT_FILE}" -o 2
    PASSWORD=$(yq eval '.admin_user_password' "${ANSIBLE_VAULT_FILE}")
    RHSM_ORG=$(yq eval '.rhsm_org' "${ANSIBLE_VAULT_FILE}")
    RHSM_ACTIVATION_KEY=$(yq eval '.rhsm_activationkey' "${ANSIBLE_VAULT_FILE}")
    OFFLINE_TOKEN=$(yq eval '.offline_token' "${ANSIBLE_VAULT_FILE}")
    PULL_SECRET=$(yq eval '.openshift_pull_secret' "${ANSIBLE_VAULT_FILE}")
    VM_NAME=device-edge-workshops
    IMAGE_NAME=rhel-8.7-x86_64-kvm.qcow2
    DISK_SIZE=200
    MEMORTY=32768
    CPU_NUM=8
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
    sudo python3 profile_generator/profile_generator.py update_yaml device-edge-workshops device-edge-workshops/template.yaml \
    --image ${IMAGE_NAME} --user cloud-user --user-password ${PASSWORD} --net-name ${NET_NAME}  --offline-token ${OFFLINE_TOKEN}  \
    --disk-size ${DISK_SIZE}  --rhnactivationkey ${RHSM_ACTIVATION_KEY} --rhnorg ${RHSM_ORG} --memory ${MEMORTY} --numcpus ${CPU_NUM}
    sudo echo ${PULL_SECRET} | sudo tee pull-secret.json
    cat pull-secret.json
    cat  kcli-profiles.yml
    ansiblesafe -f "${ANSIBLE_VAULT_FILE}" -o 1
    sudo cp kcli-profiles.yml ~/.kcli/profiles.yml
    sudo cp kcli-profiles.yml /root/.kcli/profiles.yml
    sudo cp $(pwd)/device-edge-workshops/local-inventory.yml  ~/.generated/vmfiles
    sudo cp $(pwd)/device-edge-workshops/local-inventory.yml /root/.generated/vmfiles
    echo "Creating VM ${VM_NAME}"
    sudo kcli create vm -p device-edge-workshops ${VM_NAME} --wait
}

function deploy_via_aws(){
    echo "deploying via aws"
    #export AWS_ACCESS_KEY_ID=AKIA6ABLAH1223VBD3W
    #export AWS_SECRET_ACCESS_KEY=zh6gFREbvblahblahblahfXIC5nZr51OgdKECaSIMBi9Kc
}

DEPLOYMENT_TYPE=kcli # aws

if [ $DEPLOYMENT_TYPE == "kcli" ];
then 
    deploy_via_kcli
else [ $DEPLOYMENT_TYPE == "aws" ];
    deploy_via_aws
fi

cd /opt/freeipa-workshop-deployer/2_ansible_config/
IP_ADDRESS=$(sudo kcli info vm device-edge-workshops | grep ip: | awk '{print $2}')
echo "IP Address: ${IP_ADDRESS}"
sudo python3  dynamic_dns.py --add controller "$IP_ADDRESS" 
sudo python3 dynamic_dns.py --add 'cockpit' "$IP_ADDRESS" 
sudo python3 dynamic_dns.py --add 'gitea' "$IP_ADDRESS"
sudo python3 dynamic_dns.py --add 'edge-manager' "$IP_ADDRESS"
cd ..
./2_ansible_config/populate-hostnames.sh || exit 1
cd $KCLI_SAMPLES_DIR

