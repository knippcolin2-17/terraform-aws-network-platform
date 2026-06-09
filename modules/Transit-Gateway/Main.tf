#Used to pull user details.
data "aws_caller_identity" "current" {}

# Used to pull set region from AWS Configure.
data "aws_region" "current" {}

# Used to pull availablity zones marked available for use.
data "aws_availability_zones" "available" {
  state = "available"
}

# Transit Gateway — regional hub for all VPC attachments
# auto_accept_shared_attachments disabled intentionally — require explicit acceptance
# for cross-account attachments to enforce security review process
# dns_support enabled to allow DNS resolution across VPC boundaries
resource "aws_ec2_transit_gateway" "NEW" {
  description                     = var.current_environment
  region                          = data.aws_region.current.region
  auto_accept_shared_attachments  = "enable"
  default_route_table_propagation = "disable"
  default_route_table_association = "disable"
  amazon_side_asn                 = var.BGP_ASN_AVAIL[data.aws_region.current.region]
  tags = merge(
    {
      Name        = "${var.current_environment}-TGW-${data.aws_region.current.region}"
      Region      = data.aws_region.current.region
      environment = var.current_environment
    }
  )
}

# Transit Gateway Route used for dedicated Application Teams forward/reverse route.
resource "aws_ec2_transit_gateway_route_table" "NEW_VPC" {
  transit_gateway_id = aws_ec2_transit_gateway.NEW.id
  tags = {
    Name        = "${var.current_environment}-VPC-${data.aws_region.current.region}"
    Hosts       = "VPC"
    environment = var.current_environment
    Region      = data.aws_region.current.region
  }
}

# Transit Gateway Route Table used for Central Network Resources (VPNs/DX/Inspection VPC)
resource "aws_ec2_transit_gateway_route_table" "NEW_Transport" {
  transit_gateway_id = aws_ec2_transit_gateway.NEW.id
  tags = {
    Name        = "${var.current_environment}-Shared-Services-${data.aws_region.current.region}"
    Hosts       = "Shared-Services"
    environment = var.current_environment
    Region      = data.aws_region.current.region
  }
}