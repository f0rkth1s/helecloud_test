// vpc.tf

resource "aws_vpc" "helecloud-vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  instance_tenancy     = "default"

  tags = {
    Name = "helecloud_vpc"
  }
}

resource "aws_internet_gateway" "helecloud-prod-igw" {
  vpc_id = aws_vpc.helecloud-vpc.id

  tags = {
    Name = "helecloud_prod_igw"
  }
}

// Custom route table for the VPC

resource "aws_route_table" "helecloud-prod-public-crt" {
  vpc_id = aws_vpc.helecloud-vpc.id
  route {
    cidr_block = "0.0.0.0/0"                      //associated subnet can reach everywhere
    gateway_id = aws_internet_gateway.helecloud-prod-igw.id //CRT uses this IGW to reach internet
  }
  tags = {
    Name = "helecloud-prod-public-crt"
  }
}

// subnet.tf

resource "aws_subnet" "helecloud-prod-subnet-public-1" {
  vpc_id                  = aws_vpc.helecloud-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-west-2c"

  tags = {
    Name = "helecloud_subnet_public"
  }

}

data "aws_availability_zones" "all" {}

// Associate the custom route table with the public subnet

resource "aws_route_table_association" "helecloud-prod-crta-public-subnet-1" {
  subnet_id      = aws_subnet.helecloud-prod-subnet-public-1.id
  route_table_id = aws_route_table.helecloud-prod-public-crt.id
}