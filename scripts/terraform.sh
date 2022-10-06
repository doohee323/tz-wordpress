#!/usr/bin/env bash

#https://www.middlewareinventory.com/blog/create-linux-vm-in-gcp-with-terraform-remote-exec/
#https://github.com/alfonsof/terraform-google-cloud-examples/tree/master/code/01-hello-world
#https://gist.github.com/pydevops/cffbd3c694d599c6ca18342d3625af97

set -x

cd /vagrant/resources/terraform
#export GOOGLE_APPLICATION_CREDENTIALS="/vagrant/terraform/google-key.json"
#export GOOGLE_CREDENTIALS="$(cat /vagrant/terraform/google-key.json)"

TZ_ACCOUNT=doohee323@new-nation.church
PROJECT_NAME=newnationchurch
PROJECT_ID=${PROJECT_NAME}-3239
TZ_REGION=us-west2
TZ_ZONE=us-west2-a

cp -Rf /vagrant/terraform/terraform.tfvars_template /vagrant/terraform/terraform.tfvars
sed -i "s/PROJECT_ID/${PROJECT_ID}/g" /vagrant/terraform/terraform.tfvars

#gcloud init
echo "get an authentication to click the link in CLI."
gcloud auth login

sleep 20

gcloud config configurations list
#gcloud config configurations delete ${PROJECT_NAME}
gcloud config configurations create ${PROJECT_NAME}
gcloud config configurations activate ${PROJECT_NAME}

gcloud info --format flattened
gcloud organizations list
ORG_ID=$(gcloud organizations list --format 'value(ID)')
echo "ORG_ID: ${ORG_ID}"

gcloud projects create ${PROJECT_ID} --organization=${ORG_ID} # --folder=${FOLDER_ID}
gcloud projects list --filter "parent.id=${ORG_ID} AND  parent.type=organization"
gcloud config set project ${PROJECT_ID}
gcloud config set core/account ${TZ_ACCOUNT}
gcloud config set compute/region ${TZ_REGION}
gcloud config set compute/zone ${TZ_ZONE}

BILLING_ACCOUNT_ID=`gcloud beta billing accounts list | tail -n 1 | awk '{print $1}'`
echo "BILLING_ACCOUNT_ID: ${BILLING_ACCOUNT_ID}"
gcloud beta billing projects link ${PROJECT_ID} --billing-account ${BILLING_ACCOUNT_ID}
#gcloud projects delete --quiet ${PROJECT_ID}

gcloud services enable \
  compute.googleapis.com \
  serviceusage.googleapis.com \
  iamcredentials.googleapis.com \
  cloudresourcemanager.googleapis.com \
  cloudbilling.googleapis.com \
  compute \
  container \
  --project ${PROJECT_ID}

gcloud compute zones list --filter=region:${TZ_REGION}
#gcloud compute regions list

alias tzconfig="gcloud config set account ${TZ_ACCOUNT} && \
  gcloud config set project ${PROJECT_ID} && \
  gcloud config set compute/region ${TZ_REGION} &&
  gcloud config set compute/zone ${TZ_ZONE}"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="user:${TZ_ACCOUNT}" \
  --role=roles/resourcemanager.projectIamAdmin \
  --role=roles/compute.orgSecurityResourceAdmin \
  --role=roles/iam.serviceAccountUser \
  --role=roles/container.clusterAdmin \
  --role=roles/compute.admin \
  --role=roles/owner

gcloud auth list
#gcloud auth print-access-token
#gcloud auth application-default login
#gcloud auth application-default print-access-token
#gcloud auth activate-service-account --key-file=google-key.json

gcloud iam service-accounts create tz-serviceaccount \
  --description="service account for terraform" --display-name="terraform_service_account"
SERVICE_ACCOUNT=$(gcloud iam service-accounts list | grep 'terraform_service_account' | awk '{print $2}')
echo "SERVICE_ACCOUNT: ${SERVICE_ACCOUNT}"
#gcloud iam service-accounts delete ${SERVICE_ACCOUNT}

PROJECT_ID=$(gcloud config list project --format='value(core.project)')
PROJECT_NUMBER=$(gcloud projects describe ${PROJECT_ID} --format="value(projectNumber)")
gcloud projects list --uri

gcloud iam service-accounts keys create /vagrant/resources/google-key.json \
  --iam-account ${SERVICE_ACCOUNT}
#gcloud iam service-accounts keys list --iam-account ${SERVICE_ACCOUNT} | grep '9999-'
#gcloud iam service-accounts keys delete a9cf19630c3cad5595493b3576dffdebdcb06d96 \
#  --iam-account=${SERVICE_ACCOUNT}
cat /vagrant/resources/google-key.json

cd ~/.ssh
ssh-keygen -t rsa -C ${PROJECT_ID} -P "" -f ${PROJECT_ID} -q
chmod -Rf 600 ${PROJECT_ID}*
cp -Rf ${PROJECT_ID}* /home/vagrant/.ssh
cp -Rf ${PROJECT_ID}* /vagrant/resources/terraform
chown -Rf vagrant:vagrant /home/vagrant/.ssh
chown -Rf vagrant:vagrant /vagrant/resources/terraform

gcloud projects get-iam-policy ${PROJECT_ID}

gcloud projects get-iam-policy ${PROJECT_ID} \
  --flatten="bindings[].members" \
  --format='table(bindings.role)' \
  --filter="bindings.members:${SERVICE_ACCOUNT}"

gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="serviceAccount:${SERVICE_ACCOUNT}" \
  --role=roles/resourcemanager.projectIamAdmin \
  --role=roles/iam.serviceAccountUser \
  --role=roles/compute.admin \
  --role=roles/container.clusterAdmin \
  --role=roles/compute.orgSecurityResourceAdmin \
  --role=roles/owner

gcloud compute instances list
gcloud compute instances list --project=${PROJECT_ID}

cd /vagrant/resources/terraform
export GOOGLE_APPLICATION_CREDENTIALS="/vagrant/resources/google-key.json"

terraform init
terraform plan

alias tapply='terraform apply -auto-approve'
tapply

gcloud compute instances list

public_ip=$(terraform output | grep "public_ip" | awk '{print $3}' | sed 's/"//g')

echo "
Host ${public_ip}
  StrictHostKeyChecking   no
  LogLevel                ERROR
  UserKnownHostsFile      /dev/null
  IdentitiesOnly yes
  IdentityFile /home/vagrant/.ssh/${PROJECT_ID}
" > ~/.ssh/config

echo ssh ubuntu@${public_ip}

exit 0


#################################

cd /vagrant/terraform
terraform destroy -auto-approve

rm -Rf .terraform
rm -Rf .terraform.lock.hcl
rm -Rf terraform.tfstate
rm -Rf terraform.tfstate.backup

gcloud iam service-accounts delete ${SERVICE_ACCOUNT} -q
gcloud projects delete --quiet ${PROJECT_ID} -q
rm -Rf /home/vagrant/.config

