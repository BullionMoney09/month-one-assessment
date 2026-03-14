output "bastion_public_ip" {
  description = "Public IP of the Bastion host"
  value       = aws_instance.bastion_host.public_ip
}

output "load_balancer_dns" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.techcorp_alb.dns_name
}
