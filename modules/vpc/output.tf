# Used for outputing newly created VPC details post creation to remote backend to reference for cross project collaboration.
output "aws_vpc" {
  value = aws_vpc.new_vpc.id
}