variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "project_tags" {
  description = "Tags to be applied to all resources"
  type        = map(string)
}
