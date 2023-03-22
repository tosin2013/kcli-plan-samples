#!/bin/bash 


curl -OL https://raw.githubusercontent.com/tosin2013/openshift-demos/master/quick-scripts/deploy-gitea.sh
chmod +x deploy-gitea.sh
./deploy-gitea.sh

git clone https://github.com/tosin2013/sno-quickstarts.git