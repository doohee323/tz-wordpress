#!/usr/bin/env bash

sudo apt-get install apt-transport-https ca-certificates gnupg -y
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install google-cloud-cli -y

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update -y
#sudo apt purge terraform -y
#sudo apt install terraform
sudo apt install terraform=1.1.7
terraform -v

# for GCP
#TZ_ACCOUNT=doohee323@new-nation.church
#TZ_REGION=us-west2
#TZ_ZONE=us-west2-a
#PROJECT_NAME=newnationchurch
#PROJECT_ID=${PROJECT_NAME}-3240

bash /vagrant/scripts/run_gcp.sh \
  doohee323@new-nation.church \
  us-west2 \
  us-west2-a \
  newnationchurch \
  3241

