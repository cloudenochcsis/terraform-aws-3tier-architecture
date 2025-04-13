# AWS Region
aws_region = "us-east-1"

# VPC Configuration
vpc_cidr                 = "10.0.0.0/16"
public_subnet_cidrs      = ["10.0.1.0/24", "10.0.2.0/24"]
private_app_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
private_db_subnet_cidrs  = ["10.0.5.0/24", "10.0.6.0/24"]

# Instance Configuration
instance_type = "t3.micro"
ami_id       = "ami-0230bd60aa48260c6"  # Amazon Linux 2023 AMI in us-east-1
key_name     = "3Tier-key-pair"          # Replace with your SSH key pair name

# Database Configuration
db_name     = "threetierdb"
db_username = "admin"
db_password = "YourSecurePassword123!"   # Replace with a secure password

# Project Tags
project_tags = {
  Project     = "3TierApp"
  Environment = "Production"
  Terraform   = "true"
}
