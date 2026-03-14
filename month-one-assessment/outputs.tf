output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.techcorp_vpc.id
}

output "bastion_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion.public_ip
}

output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.techcorp_alb.dns_name
}
