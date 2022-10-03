#!/usr/bin/env bash

#https://www.middlewareinventory.com/blog/create-linux-vm-in-gcp-with-terraform-remote-exec/

set -x

gcloud projects create devopsjunction

gcloud config set project devopsjunction

gcloud iam service-accounts create dj-serviceaccount --description="service account for terraform" --display-name="terraform_service_account"

gcloud iam service-accounts list

gcloud iam service-accounts keys create ~/google-key.json --iam-account dj-serviceaccount@devopsjunction.iam.gserviceaccount.com


