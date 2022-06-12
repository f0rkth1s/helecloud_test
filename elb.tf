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