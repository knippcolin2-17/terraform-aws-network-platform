locals {
  time_stamp_tags = {
    "Creation-Date" = formatdate("DD MMM YYYY hh:mm ZZZ", timestamp())
  }
}

locals {
  ami_map = {
    amazon_linux   = data.aws_ami.amazon_linux.id
    ubuntu = data.aws_ami.ubuntu.id
    windows = data.aws_ami.windows.id
  }
}

locals {
  instance_type_map = {
    small  = "t3.micro"
    medium = "t3.micro"
    large  = "t3.micro"
    xlarge = "t3.micro"
  }
}

locals {
    eligble_subnets = [
        for s in data.aws_subnet.private_subnet_details : s.id
        if s.available_ip_address_count > 5
    ]
}