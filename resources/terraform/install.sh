#!/usr/bin/env bash

#https://www.middlewareinventory.com/blog/create-linux-vm-in-gcp-with-terraform-remote-exec/

set -x

sudo apt-get install apt-transport-https ca-certificates gnupg -y
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
sudo apt-get update && sudo apt-get install google-cloud-cli -y

tz_project=constant-tracer-224322
#gcloud auth application-default login

gcloud init
#gcloud init --project=${tz_project}

#Seoul
#[50] asia-northeast3-a

BILLING_ACCOUNT_ID=`gcloud beta billing accounts list | tail -n 1 | awk '{print $1}'`

gcloud compute instances list

#gcloud projects list
#PROJECT_ID              NAME              PROJECT_NUMBER
#constant-tracer-224322  My First Project  230252599777

#gcloud projects delete dh-newnation
#gcloud projects create dh-newnation
#gcloud config set project constant-tracer-224322

#https://console.developers.google.com/apis/library/compute.googleapis.com?project=constant-tracer-224322

gcloud iam service-accounts list
#gcloud iam service-accounts keys list --iam-account dh-serviceaccount@constant-tracer-224322.iam.gserviceaccount.com
#gcloud iam service-accounts keys delete a9cf19630c3cad5595493b3576dffdebdcb06d96 \
#  --iam-account=dh-serviceaccount@constant-tracer-224322.iam.gserviceaccount.com

#gcloud iam service-accounts delete dh-serviceaccount@constant-tracer-224322.iam.gserviceaccount.com
gcloud iam service-accounts create dh-serviceaccount \
  --description="service account for terraform" --display-name="terraform_service_account"
gcloud iam service-accounts keys create ~/google-key.json \
  --iam-account dh-serviceaccount@constant-tracer-224322.iam.gserviceaccount.com
cat ~/google-key.json
cp ~/google-key.json /vagrant/resources

cd ~/.ssh
ssh-keygen -t rsa -C ${tz_project} -P "" -f ${tz_project} -q
chmod -Rf 600 ${tz_project}*
cp -Rf ${tz_project}* /home/vagrant/.ssh
cp -Rf ${tz_project}* /vagrant/resources/terraform
chown -Rf vagrant:vagrant /home/vagrant/.ssh
chown -Rf vagrant:vagrant /vagrant/resources/terraform

cd /vagrant/resources/terraform

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update -y
sudo apt purge terraform -y
#sudo apt install terraform
sudo apt install terraform=1.1.7
terraform -v

terraform init
terraform plan


