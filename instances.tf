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
  user_data = file("${path.module}/scripts/bootstrap.sh")
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




