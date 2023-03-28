#!/bin/bash
MACHINE_NAME=hypervisor.rxc4p.dynamic.opentlc.com
MACHINE_USER=lab-user
# Display a menu and get the user's choice
echo "Select a demo to build:"
echo "1. e2e-demo"
echo "2. edge-console-demo"
echo "3. hello-microshift-demo"
echo "4. ibaas-demo"
echo "5. ostree-demo"
read -p "Enter choice [1-5]: " choice

# Depending on the user's choice, set the DEMONAME variable
case $choice in
  1)
    DEMONAME="e2e-demo"
    ;;
  2)
    DEMONAME="edge-console-demo"
    ;;
  3)
    DEMONAME="hello-microshift-demo"
    ;;
  4)
    DEMONAME="ibaas-demo"
    ;;
  5)
    DEMONAME="ostree-demo"
    ;;
  *)
    echo "Invalid choice"
    exit 1
esac

# Call the build script with the selected DEMONAME
ls demos/
./scripts/build $DEMONAME

scp builds/$DEMONAME/$DEMONAME-installer.x86_64.iso $MACHINE_USER@$MACHINE_NAME:/tmp/

cat >hosts<<EOF
[client]
${MACHINE_NAME}   ansible_user=${MACHINE_USER}
EOF

sed 's/rhel-edge-kvm.iso/hello-microshift-demo-installer.x86_64.iso/g' edge_vars.yml > edge_vars_use.yml

eval $(ssh-agent)
ssh-add ~/.ssh/cluster-key
sudo ansible-playbook  -i hosts playbooks.yml -t create_kvm_vm  --extra-vars "@edge_vars_use.yml"  --private-key ~/.ssh/cluster-key -K