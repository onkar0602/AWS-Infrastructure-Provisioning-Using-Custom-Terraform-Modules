
output "vpc_id" {
  description = "Custom VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_id" {
  description = "Public subnet ID"
  value       = module.vpc.public_subnet_id
}

output "private_subnet_id" {
  description = "Private subnet ID"
  value       = module.vpc.private_subnet_id
}

output "web_instance_id" {
  description = "Public web server EC2 instance ID"
  value       = module.ec2.web_instance_id
}

output "web_public_ip" {
  description = "Public IP for browser testing"
  value       = module.ec2.web_public_ip
}

output "private_instance_id" {
  description = "Private EC2 instance ID"
  value       = module.ec2.private_instance_id
}

output "application_bucket_name" {
  description = "Application S3 bucket name"
  value       = module.s3.bucket_name
}

output "s3_gateway_endpoint_id" {
  description = "S3 Gateway VPC endpoint ID"
  value       = module.vpc_endpoint.s3_endpoint_id
}
