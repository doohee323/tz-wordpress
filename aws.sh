#!/usr/bin/env bash

ssh -i ~/.ssh/$PEM.pem ubuntu@$AWS_EC2_IP_ADDRESS 'rm -Rf /home/ubuntu/resources && rm -Rf /home/ubuntu/scripts && mkdir /home/ubuntu/resources';
scp -i ~/.ssh/$PEM.pem -r ./resources/nginx ubuntu@$AWS_EC2_IP_ADDRESS:/home/ubuntu/resources/nginx
scp -i ~/.ssh/$PEM.pem -r ./scripts ubuntu@$AWS_EC2_IP_ADDRESS:/home/ubuntu/scripts

ssh -i ~/.ssh/$PEM.pem ubuntu@$AWS_EC2_IP_ADDRESS 'sed -i "s|AWS_KEY=aws_key|AWS_KEY='$AWS_KEY'|g" /home/ubuntu/scripts/run_aws.sh'
ssh -i ~/.ssh/$PEM.pem ubuntu@$AWS_EC2_IP_ADDRESS 'cd /home/ubuntu/scripts; bash run_aws.sh'

exit 0
