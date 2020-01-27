#!/usr/bin/env bash

set -euo pipefail

PYTHON="python"
which python3 >/dev/null 2>&1 && PYTHON="python3"
$PYTHON /root/ipmi.py off
export HOME=/root
export KUBECONFIG=/root/ocp/auth/kubeconfig
export OS_CLOUD=metal3-bootstrap
export OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=registry.svc.ci.openshift.org/ocp/release:{{ tag }}
mkdir -p ocp/openshift
if [ "$(grep -q libvirtURI /root/install-config.yaml)" != "0" ] ; then
  SPACES=$(grep apiVIP /root/install-config.yaml | sed 's/apiVIP.*//' | sed 's/ /\\ /'g)
  sed -i "/hosts/i${SPACES}libvirtURI: qemu+ssh://root@{{ config_host }}/system" /root/install-config.yaml
fi
PROVISIONING_IP=$(grep libvirtURI install-config.yaml | awk -F'/' '{ print $3 }' | awk -F'@' '{ print $2 }')
ssh-keyscan -H $PROVISIONING_IP >> ~/.ssh/known_hosts
echo -e "Host=*\nStrictHostKeyChecking=no\n" > .ssh/config
if [ "$(grep -q pullSecret /root/install-config.yaml)" != "0" ] ; then
    PULLSECRET=$(cat $HOME/openshift_pull.json | tr -d [:space:])
    echo -e "pullSecret: |\n  $PULLSECRET" >> /root/install-config.yaml
fi
if [ "$(grep -q sshKey /root/install-config.yaml)" != "0" ] ; then
    SSHKEY=$(cat $HOME/.ssh/id_?sa.pub)
    echo -e "sshKey: |\n  $SSHKEY" >> /root/install-config.yaml
fi

cp install-config.yaml ocp
openshift-baremetal-install --dir ocp --log-level debug create manifests
cp metal3-config.yaml ocp/openshift/99_metal3-config.yaml
cp manifests/*.yaml ocp/openshift/
openshift-baremetal-install --dir ocp --log-level debug create cluster || true
openshift-baremetal-install --dir ocp --log-level debug wait-for install-complete || openshift-baremetal-install --dir ocp --log-level debug wait-for install-complete
