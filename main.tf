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

resource "aws_instance" "app_server" {
  ami           = "ami-0d729d2846a86a9e7"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

