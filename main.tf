terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.60.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

#create vpc; CIDR 10.0.0.0/16
resource "aws_vpc" "terravpc" {
  cidr_block                       = "10.0.0.0/16"
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames             = true
  enable_dns_support               = true
  tags = {
    "Name" = "${var.default_tags.env}-VPC"
  }
}

#Pub Sub 10.0.0.0/24
resource "aws_subnet" "pubsub" {
  count                   = 2
  vpc_id                  = aws_vpc.terravpc.id
  cidr_block              = cidrsubnet(aws_vpc.terravpc.cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  tags = {
    "Name" = "${var.default_tags.env}-Public-Subnet-${data.aws_availability_zones.availability_zone.names[count.index]}"
  }
  availability_zone = data.aws_availability_zones.availability_zone.names[count.index]
}
#Pri Sub 10.0.0.0/24
resource "aws_subnet" "prisub" {
  count      = 2
  vpc_id     = aws_vpc.terravpc.id
  cidr_block = cidrsubnet(aws_vpc.terravpc.cidr_block, 8, count.index + var.public_subnet_count)
  tags = {
    "Name" = "${var.default_tags.env}-Private-Subnet-${data.aws_availability_zones.availability_zone.names[count.index]}"
  }
  availability_zone = data.aws_availability_zones.availability_zone.names[count.index]
}
#Pub Route Table 
#Pri Route Table 
#IGW 
#NGW 