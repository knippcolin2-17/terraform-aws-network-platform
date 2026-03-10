variable "ec2_tags" {
  type = map(any)
  default = {
    ManagedBy = "Terraform"
  }
}

variable "operating_system" {
  type = string

  validation {
    condition = length(var.operating_system) > 0
    error_message = "Operating System must not be empty"
  }
}

variable "team_owner" {
    type = string

    validation {
    condition = length(var.team_owner) > 0
    error_message = "Team Owner must not be empty"
  }
}

variable "instance_count" {
  type = number
}

variable "current_environment" {
  type = string

  validation {
    condition = length(var.current_environment) > 0
    error_message = "environment name must not be empty"
  }
}

variable "application_name" {
  type = string

  validation {
    condition = length(var.application_name) > 0
    error_message = "application name must not be empty"
  }
}

variable "instance_size" {
  type = string

  validation {
    condition     = contains(["small", "medium", "large", "xlarge"], var.instance_size)
    error_message = "Instance size must be one of: small, medium, large, or xlarge"
  }
}