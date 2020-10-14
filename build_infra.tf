
variable "ssh_key_name" {
  type    = string
  default = "csye6225"
}

variable "access_key" {
  type = string
}

variable "secret_key" {
  type = string
}
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
variable "route_destination_cidr"{
  type=string
}

provider "aws" {
  # region = "us-east-1"
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
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
