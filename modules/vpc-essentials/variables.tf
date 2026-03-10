variable "security_group_tags" {
  type = map(any)
  default = {
    ManagedBy = "Terraform"
  }
}

variable "current_environment" {
  type = string
}

variable "team_owner" {
  type = string
}

variable "sg_ports" {
  type = list(number)
  default = [22, 3389, 443, 80]
}