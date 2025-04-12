output "app_security_group_id" {
  description = "ID of the app tier security group"
  value       = aws_security_group.app.id
}

output "app_lb_dns_name" {
  description = "DNS name of the internal application load balancer"
  value       = aws_lb.app.dns_name
}
