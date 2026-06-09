# Determine the set BGP ASN TGW else will default to 64512. Details passed from the Root Module.
variable "BGP_ASN_AVAIL" {
  type = map(number)
}

# Determines the appropriate envionrment to pull data blocks from AWS APIs and create resources into. Details passed from the Root Module.
variable "current_environment" {
  type = string
}