# Used for propely labeling EC2 with tags corresponding to their create date/time.
locals {
  time_stamp_tags = {
    "Creation-Date" = formatdate("DD MMM YYYY hh:mm ZZZ", timestamp())
  }
}

# Used for determining appropriate AMI to use. Works with variable operating_system which is passed from Root Module.
locals {
  ami_map = {
    amazon_linux = data.aws_ami.amazon_linux.id
    ubuntu       = data.aws_ami.ubuntu.id
    windows      = data.aws_ami.windows.id
  }
}

# Used for determining appropriate EC2 size. Workes with variable instance_size which is passed from Root Module.
locals {
  instance_type_map = {
    small  = "t3.micro"
    medium = "t3.medium"
    large  = "t3.large"
    xlarge = "t3.xlarge"
  }
}

# Used to determine which subnets with available IP space can be used as part of EC2 creation.
locals {
  eligble_subnets = [
    for s in data.aws_subnet.private_subnet_details : s.id
    if s.available_ip_address_count > 5
  ]

}