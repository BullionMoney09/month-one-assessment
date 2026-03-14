variable "region" {
  description = "AWS region for the infrastructure"
  type        = string
  default     = "us-east-1"
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

variable "key_name" {
  description = "AWS key pair name for SSH access"
  type        = string
}

variable "my_ip" {
  description = "Your public IP address for bastion SSH access"
  type        = string
}
