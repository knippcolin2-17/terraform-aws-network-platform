# Used for outputing EC2 private IPs post creation to remote backend to reference for cross project collaboration.
output "ec2_private_ips" {
  value = aws_instance.EC2_Creation[*].private_ip
}