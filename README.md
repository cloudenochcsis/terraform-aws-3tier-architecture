# AWS Three-Tier Web Architecture with Terraform

This project implements a highly available three-tier web architecture on AWS using Terraform. The architecture spans multiple Availability Zones and includes web, application, and database tiers with appropriate security and networking configurations.

## Architecture Overview

The infrastructure consists of:

### 1. Networking Layer
- VPC with custom CIDR block
- 2 Public Subnets (Web Tier)
- 2 Private Subnets (App Tier)
- 2 Private Subnets (Database Tier)
- Internet Gateway for public access
- NAT Gateway for private subnet outbound internet access
- Route tables for public and private subnets

### 2. Web Tier
- Auto Scaling Group of EC2 instances
- Application Load Balancer in public subnets
- Security group allowing HTTP/HTTPS traffic
- Apache web server installed on instances

### 3. Application Tier
- Auto Scaling Group of EC2 instances in private subnets
- Internal Application Load Balancer
- Security group allowing traffic only from web tier
- Java runtime environment installed on instances

### 4. Database Tier
- Aurora MySQL cluster in private subnets
- Primary instance and read replica
- Security group allowing traffic only from app tier

## Prerequisites

- AWS Account
- Terraform (>= 1.0)
- AWS CLI configured with appropriate credentials
- SSH key pair in your AWS region

## Backend Configuration

This project uses an S3 backend with DynamoDB state locking. Before initializing Terraform:

1. Run the backend setup script:
```bash
chmod +x setup-backend.sh
./setup-backend.sh
```

This will create:
- S3 bucket for state storage
- Versioning enabled on the bucket
- Server-side encryption
- DynamoDB table for state locking

## Quick Start

1. Clone this repository
2. Set up the backend infrastructure (see Backend Configuration above)
3. Create a `terraform.tfvars` file with your values:
```hcl
aws_region = "us-west-2"
vpc_cidr = "10.0.0.0/16"
public_subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
private_app_subnet_cidrs = ["10.0.3.0/24", "10.0.4.0/24"]
private_db_subnet_cidrs = ["10.0.5.0/24", "10.0.6.0/24"]
instance_type = "t3.micro"
ami_id = "ami-xxxxx"  # Replace with valid Amazon Linux 2 AMI ID
key_name = "your-key-pair"
db_name = "myapp"
db_username = "admin"
db_password = "your-secure-password"
```

3. Initialize Terraform:
```bash
terraform init
```

4. Review and apply the configuration:
```bash
terraform plan
terraform apply
```

## Module Structure

```
.
├── main.tf           # Main configuration file
├── variables.tf      # Input variables
├── outputs.tf        # Output values
├── modules/
│   ├── vpc/         # VPC and networking resources
│   ├── web_tier/    # Web tier resources
│   ├── app_tier/    # Application tier resources
│   └── database/    # Database tier resources
```

## Security Considerations

- All resources are tagged for better resource management
- Security groups follow the principle of least privilege
- Database credentials should be managed securely
- Private subnets have no direct internet access
- Load balancers use security groups to control traffic

## Maintenance

To update the infrastructure:
1. Modify the relevant Terraform files
2. Run `terraform plan` to review changes
3. Run `terraform apply` to apply changes

To destroy the infrastructure:
```bash
terraform destroy
```

## License

This project is licensed under the MIT License.