terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr                = var.vpc_cidr
  public_subnet_cidrs     = var.public_subnet_cidrs
  private_app_subnet_cidrs = var.private_app_subnet_cidrs
  private_db_subnet_cidrs = var.private_db_subnet_cidrs
  project_tags            = var.project_tags
}

# Web Tier Module
module "web_tier" {
  source = "./modules/web_tier"

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  instance_type     = var.instance_type
  ami_id           = var.ami_id
  key_name         = var.key_name
  project_tags     = var.project_tags
  app_sg_id        = module.app_tier.app_security_group_id
}

# App Tier Module
module "app_tier" {
  source = "./modules/app_tier"

  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_app_subnet_ids
  instance_type       = var.instance_type
  ami_id             = var.ami_id
  key_name           = var.key_name
  project_tags       = var.project_tags
  web_sg_id          = module.web_tier.web_security_group_id
  db_sg_id           = module.database.db_security_group_id
}

# Database Module
module "database" {
  source = "./modules/database"

  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_db_subnet_ids
  project_tags       = var.project_tags
  db_name            = var.db_name
  db_username        = var.db_username
  db_password        = var.db_password
}
