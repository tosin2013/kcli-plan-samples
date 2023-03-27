#!/bin/bash 
# https://github.com/redhat-et/microshift-demos

if [ -d $HOME/microshift-demos ]; then
  echo "microshift-demos directory already exists"
  cd microshift-demos
else
  cd $HOME
  git clone https://github.com/redhat-et/microshift-demos.git
  cd microshift-demos
fi 

if [ -f $HOME/.pull-secret.json ]; then
  echo "pull-secret.json already exists"
else
  echo "pull-secret.json does not exist"
   exit 1
fi

function configure_os(){
  ./scripts/configure-builder
  export  MICROSHIFT_DEV_PREVIEW=true 
  ./scripts/mirror-repos
}

sudo git a


cp builds/hello-microshift-demo/hello-microshift-demo-installer.x86_64.iso /tmp/hello-microshift-demo-installer.x86_64.iso
 sudo chown cloud-user:cloud-user -R /home/cloud-user/

cat >edge_vm.yml<<EOF
- hosts: client
  roles:
    - rhel-edge-kvm-role
EOF

cat >hosts<<EOF
[client]
192.168.1.39   ansible_user=admin
EOF



scp builds/hello-microshift-demo/hello-microshift-demo-installer.x86_64.iso admin@192.168.1.39:/tmp/
sed 's/rhel-edge-kvm.iso/hello-microshift-demo-installer.x86_64.iso/g' edge_vars.yml > playbook_vars.yml
sudo ansible-playbook  -i hosts edge_vm.yml -t create_kvm_vm  --extra-vars "@playbook_vars.yml"  --private-key ~/.ssh/cluster-key -K

sudo ansible-playbook  -i hosts edge_vm.yml -t destroy_kvm_vm --extra-vars "@your_vars.yml" -K


# Requirements for target machine
#ansible-galaxy collection install community.libvirt
#ansible-galaxy collection install ansible.posix
#ansible-galaxy collection install community.general