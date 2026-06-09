#Pull user details
data "aws_caller_identity" "current" {}

# Pull set region from AWS Configure
data "aws_region" "current" {}

# Pull availablity zones marked available for use
data "aws_availability_zones" "available" {
  state = "available"
}

# Get the Team VPC
data "aws_vpc" "team" {

  filter {
    name   = "tag:Team"
    values = [var.team_owner]
  }

  filter {
    name   = "tag:environment"
    values = [var.current_environment]
  }
}

# Get all the Team private subnets for the Team VPC
data "aws_subnets" "private" {

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.team.id]
  }

  filter {
    name   = "tag:environment"
    values = [var.current_environment]
  }

  filter {
    name   = "tag:Team"
    values = [var.team_owner]
  }

  filter {
    name   = "tag:Private"
    values = ["True"]
  }
}

# Pulling subnet details on applicable VPC. Required for VPC Endpoint resource creation.
data "aws_subnet" "private_subnet_details" {
  for_each = toset(data.aws_subnets.private.ids)
  id       = each.value
}

# Creation of AWS EC2 Connect VPC Endpoint (Secure way to access EC2 via AWS console).
resource "aws_ec2_instance_connect_endpoint" "ec2_connect_endpoint" {
  for_each           = local.private_subnets_by_az
  subnet_id          = each.value
  security_group_ids = [aws_security_group.ec2_connect_access.id]
}

# Creation of restricted Security Group used only by AWS EC2 Connect (way to remotley access EC2 via GUI).
resource "aws_security_group" "ec2_connect_access" {
  name        = "ec2_connect_access.sg"
  description = "used to by ec2 connect endpoint"
  vpc_id      = data.aws_vpc.team.id
  tags = merge(
    var.security_group_tags,
    {
      Access      = "ec2_connect_access"
      Team        = var.team_owner
      environment = var.current_environment
    }
  )

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [data.aws_vpc.team.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Used for creating the Base Security allowed for each to remotely access their resources and applications.
resource "aws_security_group" "base_access" {
  name        = "remote_access.sg"
  description = "used to allow only traffic from within the same VPC"
  vpc_id      = data.aws_vpc.team.id
  tags = merge(
    var.security_group_tags,
    {
      Access      = "Base"
      Team        = var.team_owner
      environment = var.current_environment
    }
  )

  dynamic "ingress" {
    for_each = var.sg_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [data.aws_vpc.team.cidr_block]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}