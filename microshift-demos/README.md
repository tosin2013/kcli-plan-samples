# MicroShift Demos

The [MicroShift Demos](https://github.com/redhat-et/microshift-demos) repo contains demos of various [MicroShift](https://github.com/openshift/microshift) features.

* [hello-microshift-demo](https://github.com/redhat-et/microshift-demos/tree/main/demos/hello-microshift-demo): Demonstrates a minimal RHEL for Edge with MicroShift and deploying a "Hello, MicroShift!" app on it.
* [ostree-demo](https://github.com/redhat-et/microshift-demos/tree/main/demos/ostree-demo): Become familiar with `rpm-ostree` basics (image building, updates&rollbacks, etc.) and "upgrading into MicroShift".
* [e2e-demo](https://github.com/redhat-et/microshift-demos/tree/main/demos/e2e-demo): (outdated!) Demonstrates the end-to-end process from device provisioning to management via GitOps and ACM.
* [ibaas-demo](https://github.com/redhat-et/microshift-demos/tree/main/demos/ibaas-demo): Build a RHEL for Edge ISO containing MicroShift and its dependencies in a completely automated manner using Red Hat's Hosted Image Builder service from `console.redhat.com`.

## Prerequisites
* You have deployed [qubinode navidator](https://github.com/tosin2013/quibinode_navigator) and have a working kcli setup

## To deploy it using the kcli script

```bash
$ ./deploy-vms.sh
```
