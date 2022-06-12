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
    cidr_blocks = ["0.0.0.0/0"] // Ideally best to use your machines' IP. However if it is dynamic you will need to change this in the vpc every so often. 
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

// ec2.tf

resource "aws_instance" "fe_server" {
  count = var.number_of_fe_servers

  ami           = "ami-0d729d2846a86a9e7"
  instance_type = "t2.micro"

  subnet_id = aws_subnet.helecloud-prod-subnet-public-1.id
  vpc_security_group_ids = ["${aws_security_group.ssh-http-allowed.id}"]
  key_name = aws_key_pair.aws-key.id

  provisioner "file" {
    source      = "nginx.sh"
    destination = "/tmp/nginx.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/nginx.sh",
      "sudo /tmp/nginx.sh"
    ]
  }
  
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file("${var.PRIVATE_KEY_PATH}")
  }

  tags = {
    Name = "fe_server_${count.index + 1}"
  }

}

// elb.tf

# resource "aws_elb" "fe_lb" {
#   number_of_instances = length(aws_instance.fe_server)
#   instances           = aws_instance.fe_server.*.id
# }

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