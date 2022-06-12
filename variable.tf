variable "PRIVATE_KEY_PATH" {
  default = "helecloud-aws-key"
}

variable "PUBLIC_KEY_PATH" {
  default = "helecloud-aws-key.pub"
}

variable "EC2_USER" {
  default = "ec2-user"
}

variable "number_of_fe_servers" {
  description = "Number of frontend EC2 instances"
  type        = number
  default     = 2
}