output "ec2_private_ips" {
  value = aws_instance.EC2_Creation[*].private_ip
}