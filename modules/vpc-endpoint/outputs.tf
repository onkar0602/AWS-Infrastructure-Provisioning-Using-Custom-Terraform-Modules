
output "s3_endpoint_id" {
  description = "ID of the S3 Gateway VPC Endpoint"
  value       = aws_vpc_endpoint.s3.id
}
