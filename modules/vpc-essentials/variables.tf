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

# Default ports open for Base Security Group for the newly created VPC.
variable "sg_ports" {
  type    = list(number)
  default = [22, 3389, 443, 80]
}