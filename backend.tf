terraform {
  backend "s3" {
    bucket       = "cloudenochcsis-terraform-state"
    key          = "three-tier/terraform.tfstate"
    region       = "us-east-1"
    profile      = "DevOps-Admin"
    use_lockfile = true
    encrypt      = true
  }
}
