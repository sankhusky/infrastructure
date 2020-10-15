# Infrastructure creation using Terraform

This repo contains files for building infrastructure on AWS using Terraform

It may be used to create:
- VPC
- Subnets
- Route Table
- Internet Gateway
- Associations to the route tables

## Prerequisites
- Terraform should be installed
- AWS CLI should be installed and setup


## Steps:

- Create a variables.tfvars file specifying all variables
- `terraform init` (Initialize)
- `terraform plan -var-file="variables.tfvars"` (Create a plan)
- `terraform apply -var-file="variables.tfvars"` (Apply changes)
- `terraform destroy -var-file=variables.tfvars` (Destroy all the resources and changes)


