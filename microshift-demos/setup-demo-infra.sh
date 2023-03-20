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
