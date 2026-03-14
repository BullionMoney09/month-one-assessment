output "bastion_public_ip" {
  description = "Public IP of Bastion"
  value       = aws_instance.bastion_host.public_ip
}

output "load_balancer_dns" {
  description = "ALB DNS Name"
  value       = aws_lb.techcorp_alb.dns_name
}
