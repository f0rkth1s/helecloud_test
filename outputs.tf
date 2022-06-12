# output "instance_ids" {
#   description = "IDs of EC2 instances"
#   value       = aws_instance.fe_server.*.id
#  }

output "clb_dns_name" {
  value       = aws_elb.fe_elb.dns_name
  description = "The domain name of the load balancer"
}