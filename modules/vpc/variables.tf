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

variable "vpc_tags" {
  type = map(any)
  default = {
    ManagedBy = "Terraform"
  }
}

variable "subnet_tags" {
  type = map(any)
  default = {
    ManagedBy = "Terraform"
  }
}

variable "sg_ports" {
  type = list(number)
  default = [22, 3389, 443, 80]
}

variable "public_subnet_cidr_range" {
  type = list(string)
  default = ["0", "1", "2"]
}

variable "private_subnet_cidr_range" {
  type = list(string)
  default = ["10", "11", "12"]
}

variable "new_vpc_cidr_block" {
  type = map(string)
  default = {
  us-east-1 = "10.1.0.0/16"
  us-east-2 = "10.0.0.0/16"
  us-west-1 = "10.2.0.0/16"
  us-west-2 = "10.3.0.0/16"
  }
}