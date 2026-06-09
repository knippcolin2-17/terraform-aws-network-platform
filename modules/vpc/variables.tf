# Basic Tags required for provisioning resources via automation.
variable "security_group_tags" {
  type = map(any)
  default = {
    ManagedBy = "Terraform"
  }
}

# Determines the appropriate envionrment to pull data blocks from AWS APIs and create resources into. Details passed from the Root Module.
variable "current_environment" {
  type = string
}

# Applicable Tag for the Team Owner. Details passed from the Root Module.
variable "team_owner" {
  type = string
}

# Basic Tags required for provisioning resources via automation.
variable "vpc_tags" {
  type = map(any)
  default = {
    ManagedBy = "Terraform"
  }
}

# Basic Tags required for provisioning resources via automation.
variable "subnet_tags" {
  type = map(any)
  default = {
    ManagedBy = "Terraform"
  }
}

# Default ports open for Base Security Group for the newly created VPC.
variable "sg_ports" {
  type    = list(number)
  default = [22, 3389, 443, 80]
}

# Determines the third octect to used for public subnets of the newly created VPC.
variable "public_subnet_cidr_range" {
  type    = list(string)
  default = ["0", "1", "2"]
}

# Determines the third octect to used for private subnets of the newly created VPC.
variable "private_subnet_cidr_range" {
  type    = list(string)
  default = ["10", "11", "12"]
}

# Example list of CIDRs to be used for each newly created VPC based off of set Region.
variable "new_vpc_cidr_block" {
  type = map(string)
  default = {
    us-east-1 = "10.1.0.0/16"
    us-east-2 = "10.0.0.0/16"
    us-west-1 = "10.2.0.0/16"
    us-west-2 = "10.3.0.0/16"
  }
}