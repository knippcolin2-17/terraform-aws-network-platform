# Basic Tags required for provisioning EC2.
variable "ec2_tags" {
  type = map(any)
  default = {
    ManagedBy = "Terraform"
  }
}

# This is used to determine the OS. Details passed from the Root Module.
variable "operating_system" {
  type = string

  validation {
    condition     = length(var.operating_system) > 0
    error_message = "Operating System must not be empty"
  }
}

# Applicable Tag for the Team Owner. Details passed from the Root Module.
variable "team_owner" {
  type = string

  validation {
    condition     = length(var.team_owner) > 0
    error_message = "Team Owner must not be empty"
  }
}

# Deterimines the quantity of EC2 instances created. Details passed from the Root Module.
variable "instance_count" {
  type = number
}

# Determines the appropriate envionrment to pull data blocks from AWS APIs and create EC2 into. Details passed from the Root Module.
variable "current_environment" {
  type = string

  validation {
    condition     = length(var.current_environment) > 0
    error_message = "environment name must not be empty"
  }
}

# Used for applying a symbolic name to be use for tagging. Details passed from the Root Module.
variable "application_name" {
  type = string

  validation {
    condition     = length(var.application_name) > 0
    error_message = "application name must not be empty"
  }
}

# Used to determine the number of EC2 instances required for the deployment. Details passed from the Root Module.
variable "instance_size" {
  type = string

  validation {
    condition     = contains(["small", "medium", "large", "xlarge"], var.instance_size)
    error_message = "Instance size must be one of: small, medium, large, or xlarge"
  }
}