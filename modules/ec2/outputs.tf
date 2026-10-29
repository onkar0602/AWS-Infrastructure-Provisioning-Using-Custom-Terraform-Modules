
output "web_instance_id" {
  description = "Public web server instance ID"
  value       = aws_instance.web.id
}

output "web_public_ip" {
  description = "Public IP address of the web server"
  value       = aws_instance.web.public_ip
}

output "private_instance_id" {
  description = "Private EC2 instance ID"
  value       = aws_instance.private.id
}

output "web_security_group_id" {
  description = "Web server security group ID"
  value       = aws_security_group.web.id
}

output "private_security_group_id" {
  description = "Private instance security group ID"
  value       = aws_security_group.private.id
}
