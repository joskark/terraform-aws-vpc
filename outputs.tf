output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_spot_instance_request.testing-al2023-arm.id
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_spot_instance_request.testing-al2023-arm.private_ip
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_spot_instance_request.testing-al2023-arm.public_ip
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}
