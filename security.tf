// Create security group that allows SSH/HTTP access

// front end server sg

resource "aws_security_group" "ssh-http-allowed" {
  vpc_id = aws_vpc.helecloud-vpc.id
  // Allow all outbound
  egress {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = ["0.0.0.0/0"]
    }
  // Inbound SSH from anywhere
  ingress {
      from_port = 22
      to_port   = 22
      protocol  = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  // Inbound HTTP from anywhere
  ingress {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
}

// ELB

resource "aws_security_group" "elb" {
  name = "helecloud-sg-elb"
  vpc_id = aws_vpc.helecloud-vpc.id
  // Allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  // Inbound HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

// EFS

resource "aws_security_group" "ingress-efs-test" {
   name = "ingress-efs-sg"
   vpc_id = "${aws_vpc.helecloud-vpc.id}"

   // NFS
   ingress {
     security_groups = ["${aws_security_group.ssh-http-allowed.id}"]
     from_port = 2049
     to_port = 2049
     protocol = "tcp"
   }

   // Terraform removes the default rule
   egress {
     security_groups = ["${aws_security_group.ssh-http-allowed.id}"]
     from_port = 0
     to_port = 0
     protocol = "-1"
   }
 }