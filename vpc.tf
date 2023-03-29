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
  cidr_block                       = var.vpc_cidr
  assign_generated_ipv6_cidr_block = true
  enable_dns_hostnames             = true
  enable_dns_support               = true
  tags = {
    "Name" = "${var.default_tags.env}-VPC"
  }
}
 
#Pub Sub 10.0.0.0/24
resource "aws_subnet" "pubsub" {
  count                   = var.public_subnet_count
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
  count      = var.private_subnet_count
  vpc_id     = aws_vpc.terravpc.id
  cidr_block = cidrsubnet(aws_vpc.terravpc.cidr_block, 8, count.index + var.public_subnet_count)
  tags = {
    "Name" = "${var.default_tags.env}-Private-Subnet-${data.aws_availability_zones.availability_zone.names[count.index]}"
  }
  availability_zone = data.aws_availability_zones.availability_zone.names[count.index]
}

#IGW 
resource "aws_internet_gateway" "terraigw" {
  vpc_id = aws_vpc.terravpc.id #attachment
  tags = {
    "Name" = "${var.default_tags.env}-IGW"
  }
}

#NGW 
resource "aws_nat_gateway" "terranat" {
  allocation_id = aws_eip.NAT_EIP.id
  subnet_id = aws_subnet.pubsub.0.id
  tags = {
    "Name" = "${var.default_tags.env}-NGW"
  }
}

#EIP
resource "aws_eip" "NAT_EIP" {
  vpc = true
  tags = {
    "Name" = "${var.default_tags.env}-NAT_EIP"
  }
}

#Pub Route Table 
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.terravpc.id
  tags = {
    "Name" = "${var.default_tags.env}-PubRT"
  }
}
#Pub Routes - for PubRT
resource "aws_route" "public" {
    route_table_id = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraigw.id
  }
#PubRT Association
resource "aws_route_table_association" "public" {
  count = var.public_subnet_count
  subnet_id = element(aws_subnet.pubsub.*.id, count.index)
  route_table_id = aws_route_table.public.id
}
#Pri Route Table 
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.terravpc.id
  tags = {
    "Name" = "${var.default_tags.env}-PriRT"
  }
}

#Pri Routes - for PubRT
resource "aws_route" "private" {
    route_table_id = aws_route_table.private.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.terranat.id
  }

#PriRT Association
resource "aws_route_table_association" "private" {
  count = var.private_subnet_count
  subnet_id = element(aws_subnet.prisub.*.id, count.index)
  route_table_id = aws_route_table.private.id
} 