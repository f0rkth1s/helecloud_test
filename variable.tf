# variable "PRIVATE_KEY_PATH" {
#   default = "helecloud-aws-key"
# }

variable "PUBLIC_KEY_PATH" {
  default = "helecloud-aws-key.pub"
}

variable "EC2_USER" {
  default = "ec2-user"
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type        = number
  default     = 80
}

variable "elb_port" {
  description = "The port the ELB will use for HTTP requests"
  type        = number
  default     = 80
}