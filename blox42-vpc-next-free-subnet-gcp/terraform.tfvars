# GCP Configuration
project_id = "blox42"
region     = "europe-west1"

# Infoblox Configuration
infoblox_address_block_name = "GCP VPC Address Block"

# VPC Configuration
vpc_prefix = "blox42-demo"
vpcs       = ["vpc1", "vpc2", "vpc3", "vpc4"]
subnet_cidr = "24"

# Infoblox Subnet Metadata
subnet_comment = "Terraform Demo Entry by SRiegel"
subnet_tags = {
  owner   = "sriegel"
  managed = "terraform"
  usage   = "vpc"
} 