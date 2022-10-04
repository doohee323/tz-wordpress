#!/usr/bin/env bash

#https://www.middlewareinventory.com/blog/create-linux-vm-in-gcp-with-terraform-remote-exec/

set -x

cd /vagrant/resources/terraform

tz_project=newnationchurch-3232
gcloud init --project=${tz_project}

#Seoul
#[50] asia-northeast3-a
# us-west2-a
#gcloud config set compute/zone us-west2-a

BILLING_ACCOUNT_ID=`gcloud beta billing accounts list | tail -n 1 | awk '{print $1}'`
echo "BILLING_ACCOUNT_ID: ${BILLING_ACCOUNT_ID}"
#terraform import google_project.tz-project ${tz_project}

#gcloud compute instances list

#gcloud projects delete newnationchurch-3232
gcloud projects create newnationchurch-3232
gcloud projects list
gcloud config set project ${tz_project}
gcloud auth application-default login
#https://console.developers.google.com/apis/library/compute.googleapis.com?project=newnationchurch-3232

#gcloud iam service-accounts delete tz-serviceaccount@newnationchurch-3232.iam.gserviceaccount.com
gcloud iam service-accounts create tz-serviceaccount \
  --description="service account for terraform" --display-name="terraform_service_account"
gcloud iam service-accounts list
#gcloud iam service-accounts keys list --iam-account tz-serviceaccount@newnationchurch-3232.iam.gserviceaccount.com
#gcloud iam service-accounts keys delete a9cf19630c3cad5595493b3576dffdebdcb06d96 \
#  --iam-account=tz-serviceaccount@newnationchurch-3232.iam.gserviceaccount.com
gcloud iam service-accounts keys create ~/google-key.json \
  --iam-account tz-serviceaccount@newnationchurch-3232.iam.gserviceaccount.com
cat ~/google-key.json
cp ~/google-key.json /vagrant/resources/google-key.json

cd ~/.ssh
ssh-keygen -t rsa -C ${tz_project} -P "" -f ${tz_project} -q
chmod -Rf 600 ${tz_project}*
cp -Rf ${tz_project}* /home/vagrant/.ssh
cp -Rf ${tz_project}* /vagrant/resources/terraform
chown -Rf vagrant:vagrant /home/vagrant/.ssh
chown -Rf vagrant:vagrant /vagrant/resources/terraform

gcloud compute project-info describe --project ${tz_project}

curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update -y
sudo apt purge terraform -y
#sudo apt install terraform
sudo apt install terraform=1.1.7
terraform -v

gcloud services enable \
  serviceusage.googleapis.com \
  compute.googleapis.com \
  cloudbilling.googleapis.com \
  iamcredentials.googleapis.com \
  cloudresourcemanager.googleapis.com \
  cloudbilling.googleapis.com \
  --project ${tz_project}

gcloud projects add-iam-policy-binding ${tz_project} \
  --member='user:doohee323@new-nation.church' \
  --role=roles/resourcemanager.projectIamAdmin

gcloud iam service-accounts get-iam-policy tz-serviceaccount@newnationchurch-3232.iam.gserviceaccount.com
gcloud projects get-iam-policy ${tz_project}

cd /vagrant/resources/terraform

tz_account=doohee323@new-nation.church
PROJECT_ID=newnationchurch-3232
tz_region=us-west2
tz_zone=us-west2-a

terraform init -backend-config=terraform.tfvars
#terraform workspace new gcp-demo-sbx
terraform plan
terraform apply


gcloud projects get-iam-policy ${tz_project} \
--flatten="bindings[].members" \
--format='table(bindings.role)' \
--filter="bindings.members:tz-serviceaccount@newnationchurch-3232.iam.gserviceaccount.com"

gcloud iam roles describe roles/resourcemanager.projectIamAdmin

gcloud projects add-iam-policy-binding ${tz_project} \
--member=serviceAccount:tz-serviceaccount@newnationchurch-3232.iam.gserviceaccount.com \
--role=roles/resourcemanager.projectIamAdmin

gcloud projects add-iam-policy-binding ${tz_project} \
--member='user:doohee323@new-nation.church' \
--role=roles/resourcemanager.projectIamAdmin \
--role=roles/billing.admin

gcloud iam list-grantable-roles //cloudresourcemanager.googleapis.com/projects/${tz_project}



GOOGLE_APPLICATION_CREDENTIALS="../google-key.json"



