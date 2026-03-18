variable "region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "instance_type_web" {
  description = "Instance type for web servers"
  type        = string
  default     = "t3.micro"
}

variable "instance_type_db" {
  description = "Instance type for database server"
  type        = string
  default     = "t3.small"
}

variable "my_ip" {
  description = "My public IP CIDR to allow SSH into bastion"
  type        = string
}
