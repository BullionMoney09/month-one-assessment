variable "region" {
  description = "AWS region"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "my_ip" {
  description = "Your public IP for SSH access"
  type        = string
}
variable "instance_type_bastion" {
  description = "Instance type for Bastion host"
  type        = string
  default     = "t2.micro"
}

variable "instance_type_web" {
  description = "Instance type for Web servers"
  type        = string
  default     = "t2.micro"
}

variable "instance_type_db" {
  description = "Instance type for DB server"
  type        = string
  default     = "t3.small"
}
