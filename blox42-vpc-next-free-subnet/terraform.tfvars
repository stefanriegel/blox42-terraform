# AWS Configuration
region             = "eu-central-1"
availability_zone  = "eu-central-1a"

# Infoblox Configuration
infoblox_address_block_name = "AWS VPC Address Block"

# VPC Configuration
vpc_prefix = "blox42-demo"
vpcs       = ["vpc1", "vpc2", "vpc3", "vpc4", "vpc5"]
subnet_cidr = "24"

# Infoblox Subnet Metadata
subnet_comment = "Terraform Demo Entry by SRiegel"
subnet_tags = {
  owner   = "sriegel"
  managed = "terraform"
  usage   = "vpc"
}
