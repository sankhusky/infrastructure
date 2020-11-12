
variable "ssh_key_name" {
  type    = string
  default = "csye6225"
}

# variable "access_key" {
#   type = string
# }

# variable "secret_key" {
#   type = string
# }
variable "region" {
  type = string
}

variable "subnet1_cidr" {
  type = string
}

variable "subnet2_cidr" {
  type = string
}

variable "subnet3_cidr" {
  type = string
}

variable "availability_zone1" {
  type = string
}
variable "availability_zone2" {
  type = string
}
variable "availability_zone3" {
  type = string
}
variable "route_destination_cidr" {
  type = string
}
variable "s3_bucket_name" {
  type = string
}
variable "rds_storage_size" {
  type = number
}
variable "rds_name" {
  type = string
}
variable "rds_username" {
  type = string
}
variable "rds_password" {
  type = string
}
variable "rds_identifier" {
  type = string
}
variable "dev_account" {
  type = string
}
variable "ec2_keypair_name" {
  type = string
}
variable "ec2_block_size" {
  type = number
}
variable "ec2_name_tag" {
  type = string
}
variable "dynamo_name" {
  type = string
}
variable "iam_policy_name" {
  type = string
}
variable "instance_profile_name" {
  type = string
}
variable "iam_role_name" {
  type = string
}
variable "policy_attachment_name" {
  type = string
}
variable "cicd_username" {
  type = string
}
provider "aws" {
  # region = "us-east-1"
  # access_key = var.access_key
  # secret_key = var.secret_key
  region = var.region
}

variable "availabilityZone" {
  type = string
}
variable "vpc_cidr" {
  type = string
}

variable "artifact_bucket_name" {
  type = string
}
variable "artifact_folder_name" {
  type = string
}
variable "codedeploy_application_name" {
  type = string
}
variable "codedeploy_group_name" {
  type = string
}
variable "hosted_zone_name" {
  type = string
}
locals {
  artifact_bucket_path = join("/", [var.artifact_bucket_name, var.artifact_folder_name])
}


resource "aws_vpc" "vpc_tf" {
  cidr_block                     = var.vpc_cidr
  enable_dns_hostnames           = true
  enable_dns_support             = true
  enable_classiclink_dns_support = true
  tags = {
    Name = "csye6225-tf-vpc"
  }
}

# create the Subnet
resource "aws_subnet" "subnet_tf_1" {
  vpc_id                  = aws_vpc.vpc_tf.id
  cidr_block              = var.subnet1_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone1
  tags = {
    Name = "CSYE6225 Subnet 1"
  }
} # end resource

# create the Subnet
resource "aws_subnet" "subnet_tf_2" {
  vpc_id                  = aws_vpc.vpc_tf.id
  cidr_block              = var.subnet2_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone2
  tags = {
    Name = "CSYE6225 Subnet 2"
  }
} # end resource

# create the Subnet
resource "aws_subnet" "subnet_tf_3" {
  vpc_id                  = aws_vpc.vpc_tf.id
  cidr_block              = var.subnet3_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.availability_zone3
  tags = {
    Name = "CSYE6225 Subnet 3"
  }
} # end resource


# Create the Internet Gateway
resource "aws_internet_gateway" "ig_tf" {
  vpc_id = aws_vpc.vpc_tf.id
  tags = {
    Name = "CSYE6225 Internet Gateway"
  }
} # end resource


# Create the Route Table
resource "aws_route_table" "route_table_tf" {
  vpc_id = aws_vpc.vpc_tf.id
  tags = {
    Name = "csye6225 Route Table"
  }
} # end resource

# Create the Internet Access
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.route_table_tf.id
  destination_cidr_block = var.route_destination_cidr
  gateway_id             = aws_internet_gateway.ig_tf.id
} # end resource# 

# Associate the Route Table with the Subnet
resource "aws_route_table_association" "route_table_association1" {
  subnet_id      = aws_subnet.subnet_tf_1.id
  route_table_id = aws_route_table.route_table_tf.id
} # end resource

resource "aws_route_table_association" "route_table_association2" {
  subnet_id      = aws_subnet.subnet_tf_2.id
  route_table_id = aws_route_table.route_table_tf.id
} # end resource
resource "aws_route_table_association" "route_table_association3" {
  subnet_id      = aws_subnet.subnet_tf_3.id
  route_table_id = aws_route_table.route_table_tf.id
} # end resource

resource "aws_security_group" "application_security_group" {
  name        = "application_security_group"
  description = "Application Security Group"
  vpc_id      = aws_vpc.vpc_tf.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]


  }
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "NodeJs"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "application_security_group"
  }
}

resource "aws_security_group" "db_security_group" {
  name        = "db_security_group"
  description = "DB Security Group"
  vpc_id      = aws_vpc.vpc_tf.id

  ingress {
    description     = "MySQL - From App Security Group"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.application_security_group.id]
  }


  tags = {
    Name = "DB Security Group"
  }
}


resource "aws_s3_bucket" "csye_6225_s3_bucket" {
  bucket        = var.s3_bucket_name
  acl           = "private"
  force_destroy = true

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }

  }

  lifecycle_rule {
    enabled = true
    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }
  }

  tags = {
    Name = "csye-6225-s3 bucket"
    # Environment = "Dev"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_access_block" {
  bucket = aws_s3_bucket.csye_6225_s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "csye6225-db-subnet-grp"
  subnet_ids = [aws_subnet.subnet_tf_1.id, aws_subnet.subnet_tf_2.id, aws_subnet.subnet_tf_3.id]

  tags = {
    Name = "csye6225 DB subnet group"
  }
}
resource "aws_db_instance" "rds_db_instance" {
  allocated_storage      = var.rds_storage_size
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.micro"
  name                   = var.rds_name
  username               = var.rds_username
  password               = var.rds_password
  multi_az               = false
  identifier             = var.rds_identifier
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.db_security_group.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  publicly_accessible    = false

}

data "aws_ami" "csye-ami" {
  most_recent = true

  # filter {
  #   name   = "csye6225"
  #   values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  # }

  owners = [var.dev_account] # dev
}

#-----user data---------
data "template_file" "init_instance" {
  template = file(join("", [path.module, "/init_instance.tpl"]))
  vars = {
    db_hostname        = aws_db_instance.rds_db_instance.address,
    db_username        = aws_db_instance.rds_db_instance.username
    db_password        = aws_db_instance.rds_db_instance.password
    db_endpoint        = aws_db_instance.rds_db_instance.endpoint
    bucket_name        = aws_s3_bucket.csye_6225_s3_bucket.bucket
    db_name            = aws_db_instance.rds_db_instance.name
    aws_default_region = var.region
  }
}
# If there's connection issue, try connecting the gateway by specifying the gateway_id in association, instead of subnet id for each subnet -- NOT NEEDED
resource "aws_instance" "csye6225-ec2instance" {
  ami                         = data.aws_ami.csye-ami.id
  key_name                    = var.ec2_keypair_name
  instance_type               = "t2.micro"
  vpc_security_group_ids      = [aws_security_group.application_security_group.id]
  subnet_id                   = aws_subnet.subnet_tf_1.id
  associate_public_ip_address = true
  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.ec2_block_size
    delete_on_termination = true
  }
  disable_api_termination = false
  tags = {
    "Name" = var.ec2_name_tag
  }
  user_data            = data.template_file.init_instance.rendered
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
}

resource "aws_dynamodb_table" "csye6225-dynamodb-table" {
  name           = var.dynamo_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  # ttl {
  #   attribute_name = "TimeToExist"
  #   enabled        = false
  # }

  tags = {
    Name = "csye6225-dynamodb-table"
  }
}

# IAM Policy
resource "aws_iam_policy" "policy" {
  name        = var.iam_policy_name
  path        = "/"
  description = "WebAppS3 policy"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
              "s3:PutObject",
              "s3:GetObject",
              "s3:DeleteObject",
              "s3:*Object"
            ],
            "Effect": "Allow",
            "Resource": [
                "arn:aws:s3:::${var.s3_bucket_name}",
                "arn:aws:s3:::${var.s3_bucket_name}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = var.instance_profile_name
  role = aws_iam_role.ec2_iam_role.name
}
# IAM role

resource "aws_iam_role" "ec2_iam_role" {
  name = var.iam_role_name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = {
    Name = "EC2-CSYE6225"
  }
}

#Attachment

resource "aws_iam_policy_attachment" "iam_policy_attachment" {
  name       = var.policy_attachment_name
  roles      = [aws_iam_role.ec2_iam_role.name]
  policy_arn = aws_iam_policy.policy.arn
}

# --------CI/CD config-----------
# Fetch user and attach policies
data "aws_iam_user" "cicd_user" {
  user_name = var.cicd_username
}

resource "aws_iam_policy" "cicd_download_policy" {
  name        = "CodeDeploy-EC2-S3"
  description = "This policy is required for EC2 instances to download latest application revision from S3."
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:GetObject",
                "s3:GetObjectVersion",
                "s3:ListBucket"
            ],
            "Effect": "Allow",
            "Resource": [
              "arn:aws:s3:::${var.artifact_bucket_name}",
              "arn:aws:s3:::${var.artifact_bucket_name}/*",
              "arn:aws:s3:::${local.artifact_bucket_path}/*"
              ]
        }
    ]
}
  EOF
}

resource "aws_iam_policy" "cicd_upload_policy" {
  name        = "GH-Upload-To-S3"
  description = "This policy allows GitHub Actions to upload artifacts from latest successful build to dedicated S3 bucket used by CodeDeploy"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:PutObjectAcl",
                "s3:Get*",
                "s3:List*"                
            ],
            "Resource": [
              "arn:aws:s3:::${var.artifact_bucket_name}",
              "arn:aws:s3:::${var.artifact_bucket_name}/*",
              "arn:aws:s3:::${local.artifact_bucket_path}/*"
            ]
        }
    ]
}
  EOF
}

# get current aws caller identity
data "aws_caller_identity" "current" {}

# TODO: check if the "*" in resources in below policy has to be replaced
resource "aws_iam_policy" "codedeploy_policy" {
  name        = "GH-Code-Deploy"
  description = "This policy allows GitHub Actions to call CodeDeploy APIs to initiate application deployment on EC2 instances"
  policy      = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:RegisterApplicationRevision",
        "codedeploy:GetApplicationRevision"
      ],
      "Resource": [
        "arn:aws:codedeploy:${var.region}:${data.aws_caller_identity.current.account_id}:application:${var.codedeploy_application_name}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:CreateDeployment",
        "codedeploy:GetDeployment"
      ],
      "Resource": [
        "arn:aws:codedeploy:${var.region}:${data.aws_caller_identity.current.account_id}:deploymentgroup:${var.codedeploy_application_name}/${var.codedeploy_group_name}"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:GetDeploymentConfig"
      ],
      "Resource": [                
        "arn:aws:codedeploy:${var.region}:${data.aws_caller_identity.current.account_id}:deploymentconfig:CodeDeployDefault.AllAtOnce"
      ]
    }
  ]
}
  EOF
}


resource "aws_iam_role" "CodeDeployServiceRole" {
  name = "CodeDeployServiceRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "codedeploy.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
  role       = aws_iam_role.CodeDeployServiceRole.name
}

# Remove below after everything works
# resource "aws_iam_user_policy_attachment" "cicd_download_policy_attach" {
#   user       = data.aws_iam_user.cicd_user.user_name
#   policy_arn = aws_iam_policy.cicd_download_policy.arn
# }

# attaching the download policy to EC2 Role

resource "aws_iam_role_policy_attachment" "ec2_codedeploy_policy_attachment" {
  role       = aws_iam_role.ec2_iam_role.name
  policy_arn = aws_iam_policy.cicd_download_policy.arn
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attachment" {
  role       = aws_iam_role.ec2_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_user_policy_attachment" "cicd_upload_policy_attach" {
  user       = data.aws_iam_user.cicd_user.user_name
  policy_arn = aws_iam_policy.cicd_upload_policy.arn
}

resource "aws_iam_user_policy_attachment" "codedeploy_policy_attach" {
  user       = data.aws_iam_user.cicd_user.user_name
  policy_arn = aws_iam_policy.codedeploy_policy.arn
}

resource "aws_codedeploy_app" "codedeploy_app" {
  compute_platform = "Server"
  name             = var.codedeploy_application_name
}


resource "aws_codedeploy_deployment_group" "codedeploy_deployment_group" {
  app_name              = aws_codedeploy_app.codedeploy_app.name
  deployment_group_name = var.codedeploy_group_name
  service_role_arn      = aws_iam_role.CodeDeployServiceRole.arn
  deployment_config_name = "CodeDeployDefault.AllAtOnce"
  deployment_style {
    deployment_option = "WITHOUT_TRAFFIC_CONTROL"
    deployment_type = "IN_PLACE"
  }

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = var.ec2_name_tag
    }
  }


}

resource "aws_eip" "ec2_eip" {
  instance = aws_instance.csye6225-ec2instance.id
  vpc = true
}

data "aws_route53_zone" "selected_zone" {
  name         = var.hosted_zone_name
  private_zone = false
}

resource "aws_route53_record" "ec2_dns_record" {
  zone_id = data.aws_route53_zone.selected_zone.zone_id
  name    = "www.api.${data.aws_route53_zone.selected_zone.name}"
  type    = "A"
  ttl     = "60"
  records = [aws_eip.ec2_eip.public_ip]
}

