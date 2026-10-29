
variable "project_name" {
  description = "Project name for resource tags"
  type        = string
}

variable "vpc_id" {
  description = "ID of the custom VPC"
  type        = string
}

variable "private_route_table_id" {
  description = "ID of the private subnet route table"
  type        = string
}

variable "application_bucket_arn" {
  description = "ARN of the application S3 bucket"
  type        = string
}
