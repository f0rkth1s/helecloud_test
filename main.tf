terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  backend "s3" {
    bucket = "terraform-state-buckets"
    key    = "helocloud"
    region = "eu-west-2"
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = "eu-west-2"
}

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

// 

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

// Associate the custom route table with the public subnet

resource "aws_route_table_association" "helecloud-prod-crta-public-subnet-1" {
  subnet_id      = aws_subnet.helecloud-prod-subnet-public-1.id
  route_table_id = aws_route_table.helecloud-prod-public-crt.id
}

// Create security group that allows SSH/HTTP access

resource "aws_security_group" "ssh-http-allowed" {
vpc_id = aws_vpc.helecloud-vpc.id
egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "aws-key" {
  key_name   = "helocloud-aws-key"
  public_key = file(var.PUBLIC_KEY_PATH)// Path is in the variables file
}

// launch config

resource "aws_launch_configuration" "fe_servers" {
  image_id        = "ami-0d729d2846a86a9e7"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.ssh-http-allowed.id]
  key_name = aws_key_pair.aws-key.id
  user_data = file("${path.module}/nginx.sh")
  associate_public_ip_address = true
  lifecycle {
    create_before_destroy = true
  }
  # tags = {
  #    Name = "fe_server_${count.index + 1}"
  #  }
}

resource "aws_autoscaling_group" "fe_servers_asg" {
  launch_configuration      = aws_launch_configuration.fe_servers.id
  vpc_zone_identifier       = [aws_subnet.helecloud-prod-subnet-public-1.id]
  min_size = 2
  max_size = 10
  load_balancers    = [aws_elb.fe_elb.name]
  health_check_type = "ELB"
  tag {
    key                 = "Name"
    value               = "fe_server"
    propagate_at_launch = true
  }
}

resource "aws_elb" "fe_elb" {
  name               = "helecloud-fe-elb"
  security_groups    = [aws_security_group.elb.id]
  //availability_zones = data.aws_availability_zones.all.names
  subnets            = [aws_subnet.helecloud-prod-subnet-public-1.id]
  health_check {
    target              = "HTTP:${var.server_port}/"
    interval            = 30
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  # This adds a listener for incoming HTTP requests.
  listener {
    lb_port           = var.elb_port
    lb_protocol       = "http"
    instance_port     = var.server_port
    instance_protocol = "http"
  }
}

resource "aws_security_group" "elb" {
  name = "helecloud-sg-elb"
  vpc_id = aws_vpc.helecloud-vpc.id
  # Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Inbound HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// efs.tf
resource "aws_efs_file_system" "fe-shared-efs" {
  creation_token = "efs-example"
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  encrypted = "true"
  tags = {
     Name = "EfsExample"
  }
}