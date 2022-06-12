# output "instance_ids" {
#   description = "IDs of EC2 instances"
#   value       = aws_instance.fe_server.*.id
#  }

output "clb_dns_name" {
  value       = aws_elb.fe_elb.dns_name
  description = "The domain name of the front end load balancer"
}

output "efs_dns_name" {
  value       = aws_efs_mount_target.fe-efs-mt.dns_name
  description = "The domain name of the front end load balancer"
}