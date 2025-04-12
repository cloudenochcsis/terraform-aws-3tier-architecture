output "alb_dns_name" {
  description = "DNS name of the application load balancer"
  value       = module.web_tier.alb_dns_name
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "IDs of the private application subnets"
  value       = module.vpc.private_app_subnet_ids
}

output "private_db_subnet_ids" {
  description = "IDs of the private database subnets"
  value       = module.vpc.private_db_subnet_ids
}

output "aurora_endpoint" {
  description = "Aurora cluster endpoint"
  value       = module.database.cluster_endpoint
}

output "aurora_reader_endpoint" {
  description = "Aurora cluster reader endpoint"
  value       = module.database.reader_endpoint
}
