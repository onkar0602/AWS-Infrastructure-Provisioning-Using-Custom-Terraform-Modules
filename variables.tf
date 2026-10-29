
variable "project_name" {
  description = "Prefix for project resources"
  type        = string
  default     = "terraform-exam"
}

variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "us-east-1"
}

variable "ssh_allowed_cidr" {
  description = "Your public IP address in CIDR format, ending in /32"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.ssh_allowed_cidr))
    error_message = "Provide a valid IPv4 CIDR, such as 203.0.113.10/32."
  }
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
