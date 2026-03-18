output "bastion_public_ip" {
  value = aws_instance.bastion_host.public_ip
}

output "load_balancer_dns" {
  value = aws_lb.techcorp_alb.dns_name
}
