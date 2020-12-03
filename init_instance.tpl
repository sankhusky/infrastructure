#!/bin/bash

sudo echo "export DB_HOSTNAME=${db_hostname}" >> /etc/environment
sudo echo "export DB_USERNAME=${db_username}" >> /etc/environment
sudo echo "export DB_PASSWORD=${db_password}" >> /etc/environment
sudo echo "export DB_NAME=${db_name}" >> /etc/environment
sudo echo "export DB_ENDPOINT=${db_endpoint}" >> /etc/environment
sudo echo "export Bucket=${bucket_name}" >> /etc/environment
sudo echo "export AWS_DEFAULT_REGION=${aws_default_region}" >> /etc/environment
sudo echo "export IS_EC2=true" >> /etc/environment
sudo echo "export SNS_ARN=${sns_arn}" >> /etc/environment
sudo echo "export ENV=${environment}" >> /etc/environment
sudo apt-get update -y
sudo apt-get install unzip
