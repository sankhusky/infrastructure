#!/bin/bash

sudo echo "export DB_HOSTNAME=${db_hostname}" >> /home/ubuntu/.bashrc
sudo echo "export DB_USERNAME=${db_username}" >> /home/ubuntu/.bashrc
sudo echo "export DB_PASSWORD=${db_password}" >> /home/ubuntu/.bashrc
sudo echo "export DB_NAME=${db_name}" >> /home/ubuntu/.bashrc
sudo echo "export DB_ENDPOINT=${db_endpoint}" >> /home/ubuntu/.bashrc
sudo echo "export Bucket=${bucket_name}" >> /home/ubuntu/.bashrc
sudo echo "export AWS_DEFAULT_REGION=${aws_default_region}" >> /home/ubuntu/.bashrc
sudo echo "export IS_EC2=true" >> /home/ubuntu/.bashrc
sudo apt-get update -y
sudo apt-get install unzip
