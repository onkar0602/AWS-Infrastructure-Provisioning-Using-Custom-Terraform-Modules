
variable "project_name" {
  type        = string
  description = "Project name prefix"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the security groups"
}

variable "public_subnet_id" {
  type        = string
  description = "Public subnet ID"
}

variable "private_subnet_id" {
  type        = string
  description = "Private subnet ID"
}

variable "instance_type" {
  type        = string
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "key_name" {
  type        = string
  description = "Existing AWS EC2 key pair name"
}

variable "ssh_allowed_cidr" {
  type        = string
  description = "Authorized public IP in CIDR format, for example 203.0.113.10/32"
}

variable "private_instance_profile_name" {
  type        = string
  description = "IAM instance profile for private EC2 S3 access"
}

variable "application_bucket_arn" {
  type        = string
  description = "ARN of the application S3 bucket"
}
