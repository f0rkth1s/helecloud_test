output "instance_ids" {
  description = "IDs of EC2 instances"
  value       = aws_instance.fe_server.*.id
 }