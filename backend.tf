terraform {
  backend "s3" {
    bucket         = "cloudenochcsis-terraform-state"
    key            = "three-tier/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
