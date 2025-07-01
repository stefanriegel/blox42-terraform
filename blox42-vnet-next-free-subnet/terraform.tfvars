# Azure Configuration
region         = "West Europe"
resource_group = "blox42-rg"

# Infoblox Configuration
infoblox_address_block_name = "Azure VNET Address Block"

# VNET Configuration
vnet_prefix = "blox42-demo"
vnets       = ["vnet1", "vnet2", "vnet3", "vnet4", "vnet5"]
subnet_cidr = "24"

# Infoblox Subnet Metadata
subnet_comment = "Terraform Demo Entry by SRiegel"
subnet_tags = {
  owner   = "sriegel"
  managed = "terraform"
  usage   = "vnet"
}
