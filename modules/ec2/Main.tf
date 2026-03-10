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

# Get details for each individual Private Subnet (Required: to Check available IPs per subnet)
data "aws_subnet" "private_subnet_details" {
  for_each = toset(data.aws_subnets.private.ids)
  id = each.value
}

# Get the Base Security Group for Team VPC
data "aws_security_group" "base" {

  filter {
    name   = "tag:Team"
    values = [var.team_owner]
  }
  
filter {
      name   = "tag:environment"
    values = [var.current_environment]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.team.id]
  }

   filter {
    name   = "tag:Team"
    values = [var.team_owner]
  }

  filter {
    name   = "tag:Access"
    values = ["Base"]
  }
}

# Get latest AMI for Amazon Linux
data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  owners = ["amazon"]
}

# Get latest AMI for Ubuntu
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]  # Canonical
}

# Get latest AMI for Windows
data "aws_ami" "windows" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Windows_Server-2022-English-Full-Base-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["801119661308"]  # AWS official Windows AMIs
}

resource "aws_instance" "EC2_Creation" {
count = var.instance_count
subnet_id = local.eligble_subnets[count.index % length(local.eligble_subnets)]
  ami                         = local.ami_map[var.operating_system]
  associate_public_ip_address = "false"
  instance_type = local.instance_type_map[var.instance_size]
  security_groups = [data.aws_security_group.base.id]

  lifecycle {
    ignore_changes = [
      ami,
    user_data
    ]
  }

  tags = merge(
    var.ec2_tags,
    local.time_stamp_tags,
    {
      Name   = "ec2-${var.application_name}-${count.index + 1}"
      Team = var.team_owner
      environment = var.current_environment
      OS     = var.operating_system
      Region = data.aws_region.current.region
      app = var.application_name
    }
  )
}