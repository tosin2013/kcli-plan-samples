export ANSIBLE_VAULT_FILE="$HOME/quibinode_navigator/inventories/localhost/group_vars/control/vault.yml"
ansiblesafe -f "${ANSIBLE_VAULT_FILE}" -o 2
PASSWORD=$(yq eval '.admin_user_password' "${ANSIBLE_VAULT_FILE}")
RHSM_ORG=$(yq eval '.rhsm_org' "${ANSIBLE_VAULT_FILE}")
RHSM_ACTIVATION_KEY=$(yq eval '.rhsm_activationkey' "${ANSIBLE_VAULT_FILE}")
sudo rm -rf kcli-profiles.yml
sudo python3 profile_generator/profile_generator.py update_yaml ansible-aap ansible-aap/ansible-aap.yml --image rhel-baseos-9.1-x86_64-kvm.qcow2 --user $USER --user-password ${PASSWORD} --rhnorg ${RHSM_ORG} --rhnactivationkey ${RHSM_ACTIVATION_KEY}
sudo python3 profile_generator/profile_generator.py update_yaml ansible-hub ansible-aap/ansible-hub.yml --image rhel-baseos-9.1-x86_64-kvm.qcow2 --user $USER --user-password ${PASSWORD} --rhnorg ${RHSM_ORG} --rhnactivationkey ${RHSM_ACTIVATION_KEY}
ansiblesafe -f "${ANSIBLE_VAULT_FILE}" -o 1
sudo cp kcli-profiles.yml ansible-aap/plan.yml
sudo kcli create plan -f ansible-aap/plan.yml


```
sudo kcli delete plan dope-amouranth
sudo kcli delete plan -f ansible-aap/plan.yml
```