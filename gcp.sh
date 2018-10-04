#!/usr/bin/env bash

set -x

ssh -i ~/.ssh/$PRIKEY ubuntu@$GCP_IP_ADDRESS 'rm -Rf /home/ubuntu/resources && rm -Rf /home/ubuntu/scripts && mkdir /home/ubuntu/resources';
scp -i ~/.ssh/$PRIKEY -r ./resources/nginx ubuntu@$GCP_IP_ADDRESS:/home/ubuntu/resources/nginx
scp -i ~/.ssh/$PRIKEY -r ./scripts ubuntu@$GCP_IP_ADDRESS:/home/ubuntu/scripts

ssh -i ~/.ssh/$PRIKEY ubuntu@$GCP_IP_ADDRESS 'sed -i "s|GCP_KEY=gcp_key|GCP_KEY='$GCP_KEY'|g" /home/ubuntu/scripts/run_gcp.sh'
ssh -i ~/.ssh/$PRIKEY ubuntu@$GCP_IP_ADDRESS 'cd /home/ubuntu/scripts; bash run_gcp.sh'

exit 0
