#Pull user details
data "aws_caller_identity" "current" {}

# Pull set region from AWS Configure
data "aws_region" "current" {}

# Pull availablity zones marked available for use
data "aws_availability_zones" "available" {
    state = "available"
}

# Get Transit Gateway Details for specific region/environment
data "aws_ec2_transit_gateway" "region_tgw" {
    
    filter {
    name   = "tag:Region"
    values = [data.aws_region.current.region]
  }

filter {
    name   = "tag:environment"
    values = [var.current_environment]
  }
}

# Get Transit Gateway Route Table Details for specific region/environment used by VPCs
data "aws_ec2_transit_gateway_route_table" "region_tgw_rt_vpc" {
    
    filter {
    name   = "tag:Region"
    values = [data.aws_region.current.region]
  }

filter {
    name   = "tag:environment"
    values = [var.current_environment]
  }

  filter {
    name   = "tag:Hosts"
    values = ["VPC"]
  }
}

# Get Transit Gateway Route Table Details for specific region/environment used by Shared Services (Peering Connections)
data "aws_ec2_transit_gateway_route_table" "region_tgw_rt_shared_service" {
    
    filter {
    name   = "tag:Region"
    values = [data.aws_region.current.region]
  }

filter {
    name   = "tag:environment"
    values = [var.current_environment]
  }

  filter {
    name   = "tag:Hosts"
    values = ["Shared-Services"]
  }
}

resource "aws_vpc" "new_vpc" {
  cidr_block           = var.new_vpc_cidr_block[data.aws_region.current.region]
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = merge(
    var.vpc_tags,
    {
      Region = data.aws_region.current.region
      Team = var.team_owner
      environment = var.current_environment
      Name = "${var.team_owner}-${var.current_environment}"
    }
  )
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.new_vpc.id

  tags = merge(
    {
      Region = data.aws_region.current.region
      Team = var.team_owner
      environment = var.current_environment
    Name = "${var.team_owner}-${var.current_environment}-IGW"
  }
  )
}
resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  vpc_id            = aws_vpc.new_vpc.id
  allocation_id = aws_eip.nat.id
  connectivity_type = "public"
  availability_mode = "regional"
  depends_on = [aws_internet_gateway.IGW]

  tags = merge(
    {
      Region = data.aws_region.current.region
      Team = var.team_owner
      environment = var.current_environment
    Name = "${var.team_owner}-${var.current_environment}-nat-gw"
  }
  )
}

resource "aws_subnet" "public" {

  for_each = toset(var.public_subnet_cidr_range)

  cidr_block = cidrsubnet(
    aws_vpc.new_vpc.cidr_block,
    8,
    each.value
  )

  vpc_id            = aws_vpc.new_vpc.id
  availability_zone = data.aws_availability_zones.available.names[each.key % length(data.aws_availability_zones.available.names)]

  tags = merge(
    var.subnet_tags,
    {
      Region  = data.aws_region.current.region
      Team = var.team_owner
      environment = var.current_environment
      Private = "False"
      Name    = "Public-${each.value + 1}"
    }
  )
}

resource "aws_subnet" "private" {

  for_each = toset(var.private_subnet_cidr_range)

  cidr_block = cidrsubnet(
    aws_vpc.new_vpc.cidr_block,
    8,
    each.value
  )

  vpc_id            = aws_vpc.new_vpc.id
  availability_zone = data.aws_availability_zones.available.names[each.key % length(data.aws_availability_zones.available.names)]

  tags = merge(
    var.subnet_tags,
    {
      Region  = data.aws_region.current.region
      Team = var.team_owner
      Private = "True"
      environment = var.current_environment
      Name    = "Private-${each.value + 1}"
    }
  )
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.new_vpc.id

  route {
    cidr_block = "10.0.0.0/8"
    gateway_id = data.aws_ec2_transit_gateway.region_tgw.id
  }

route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }
tags = merge(
   {
    environment = var.current_environment
    Region  = data.aws_region.current.region
    Name = "Private-RT"
  }
  )
}

resource "aws_route_table_association" "private_subnet_association" {
  for_each = aws_subnet.private

  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt.id
}

  resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.new_vpc.id

  route {
    cidr_block = "10.0.0.0/8"
    gateway_id = data.aws_ec2_transit_gateway.region_tgw.id
  }

route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = merge(
   {
    environment = var.current_environment
    Region  = data.aws_region.current.region
    Name = "Public-RT"
  }
  )
}

resource "aws_route_table_association" "public_subnet_association" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_ec2_instance_connect_endpoint" "ec2_connect_endpoint" {
  subnet_id = values(aws_subnet.private)[0].id
  security_group_ids = [aws_security_group.ec2_connect_access.id]
}

resource "aws_security_group" "ec2_connect_access" {
  name        = "ec2_connect_access.sg"
  description = "used to by ec2 connect endpoint"
  vpc_id      = aws_vpc.new_vpc.id
  tags        = merge(
    var.security_group_tags,
    {
        Access = "ec2_connect_access"
        Team = var.team_owner
        environment = var.current_environment
    }
  )

  ingress {
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = [aws_vpc.new_vpc.cidr_block]
    }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "base_access" {
  name        = "remote_access.sg"
  description = "used to allow only traffic from within the same VPC"
  vpc_id      = aws_vpc.new_vpc.id
  tags        = merge(
    var.security_group_tags,
    {
        Access = "Base"
        Team = var.team_owner
        environment = var.current_environment
    }
  )

  dynamic "ingress" {
    for_each = var.sg_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [aws_vpc.new_vpc.cidr_block]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "new_vpc_attachment" {
  subnet_ids         = values(aws_subnet.private)[*].id
  transit_gateway_id = data.aws_ec2_transit_gateway.region_tgw.id

  vpc_id             = aws_vpc.new_vpc.id
}

resource "aws_ec2_transit_gateway_route_table_association" "new_vpc_association" {
  transit_gateway_attachment_id = aws_ec2_transit_gateway_vpc_attachment.new_vpc_attachment.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.region_tgw_rt_vpc.id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "new_vpc_propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.new_vpc_attachment.id
  transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.region_tgw_rt_vpc.id
}