variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "IDs of the private subnets"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
}

variable "project_tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
}

variable "web_sg_id" {
  description = "ID of the Web tier security group"
  type        = string
}

variable "db_sg_id" {
  description = "ID of the Database tier security group"
  type        = string
}
