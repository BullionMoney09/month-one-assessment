output "bastion_public_ip" {
  description = "Public IP of bastion host"
  value = aws_instance.bastion.public_ip
}

output "alb_dns" {
  description = "Load balancer DNS"
  value = aws_lb.alb.dns_name
}
