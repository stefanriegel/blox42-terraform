# AWS Configuration
region = "eu-central-1"

# Infoblox Configuration
# Make sure this address block exists in your Infoblox instance
# You can reuse an existing one or create a new one
infoblox_address_block_name = "AWS VPC Address Block"

# VPC Configuration
# Option 1: Create new VPC/subnet (set vm_subnet_id = null)
# Option 2: Use existing subnet from blox42-vpc-next-free-subnet-aws project
# First VPC: blox42-demo-vpc1, Subnet: subnet-blox42-demo-vpc1
vm_subnet_id = null  # Set to subnet ID if using existing subnet from VPC project
existing_infoblox_subnet_name = "subnet-blox42-demo-vpc1"  # Name of existing Infoblox subnet
vpc_prefix = "blox42-demo"
vm_vpc_name = "vpc1"  # This matches the first VPC from the VPC project
subnet_cidr = "24"
availability_zone = "eu-central-1a"

# Infoblox Subnet Metadata
subnet_comment = "Terraform Demo Entry by SRiegel"
subnet_tags = {
  owner   = "sriegel"
  managed = "terraform"
  usage   = "vm"
}

# VM Configuration
vm_name = "blox42-demo-vm-aws"
instance_type = "t3.nano"
ami_id = "ami-0c55825bb0a77f4cf"  # Amazon Linux 2 AMI in eu-central-1 (Frankfurt)
key_name = "blox42-key"  # Replace with your SSH key pair name

# Infoblox Comment
vm_comment = "Terraform-Managed AWS EC2"

# Tags for Infoblox
vm_tags = {
  owner         = "SRiegel"
  managed       = "Terraform Managed"
  cloud         = "aws"
  os            = "Linux"
  cost_center   = "n/a"
  hub_type      = "non-prod"
}

# DNS Zone
dns_zone = "aws.blox42.rocks" 