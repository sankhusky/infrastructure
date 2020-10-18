
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

# resource "aws_security_group" "app_sec_group" {
#   name        = "app_security_group"
#   description = "Application Security Group"
#   vpc_id      = aws_vpc.vpc_tf.id

#   ingress {
#     description = "TLS from VPC"
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = [aws_vpc.main.cidr_block]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "allow_tls"
#   }
# }


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
  bucket        = "webapp.sanket.pimple"
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
    Name        = "csye-6225-s3 bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_public_access_block" "s3_access_block" {
  bucket = aws_s3_bucket.csye_6225_s3_bucket.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls = true
  restrict_public_buckets = true
}


resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "csye6225-db-subnet-grp"
  subnet_ids = [aws_subnet.subnet_tf_1.id, aws_subnet.subnet_tf_2.id,aws_subnet.subnet_tf_3.id]

  tags = {
    Name = "csye6225 DB subnet group"
  }
}
resource "aws_db_instance" "rds_db_instance" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "csye6225"
  username             = "csye6225fall2020"
  password             = "Cloud123#"
  multi_az = false
  identifier = "csye6225-f20"
  vpc_security_group_ids = [aws_security_group.db_security_group.id]
  db_subnet_group_name = "csye6225-db-subnet-grp"
  publicly_accessible = false
  skip_final_snapshot = true
}



# If there's connection issue, try connecting the gateway by specifying the gateway_id in association, instead of subnet id for each subnet

# resource "aws_instance" "ec2instance" {
#   ami = "ami-07ebfd5b3428b6f4d"
#   instance_type = "t2.micro"
#   key_name = "${var.ssh_key_name}"
#   vpc_security_group_ids = ["sg-04b24925d3c5dd9ad"]
#   subnet_id = "subnet-0fa5ba21"
#   associate_public_ip_address = true
#   root_block_device {
#       volume_type = "gp2"
#       volume_size = 8
#   }
# }


# resource "aws_instance" "ec2instance-assignment" {
#   ami = "ami-0e0a4a3a233572ff2"
#   instance_type = "t2.micro"
#   key_name = var.ssh_key_name
#   subnet_id = aws_subnet.subnet_1_assignment.id
#   vpc_security_group_ids = [aws_security_group.application_security_group.id]
#   associate_public_ip_address = true
#   root_block_device {
#       volume_type = "gp2"
#       volume_size = 8
#   }
# tags = {
#     Name: "ec2instance-assignment"
# }

# }
