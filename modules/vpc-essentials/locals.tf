locals {
  private_subnets_by_az = {
    for subnet in data.aws_subnet.private_subnet_details :
    subnet.availability_zone => subnet.id
  }
}
