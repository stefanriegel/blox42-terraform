# Azure Konfiguration
region         = "West Europe"
resource_group = "blox42-rg"

# VNET/Subnet für die VM
vm_vnet_name   = "blox42-demo-vnet1"
vm_subnet_name = "subnet-blox42-demo-vnet1"

# VM Konfiguration
vm_name        = "blox42-demo-vm"
vm_size        = "Standard_B2s"
admin_username = "adminuser"
admin_password = "SuperSecurePassword123!"

# Infoblox Comment
vm_comment = "Terraform-Managed Azure VM"

# Tags für Infoblox
vm_tags = {
  owner         = "SRiegel"
  managed       = "Terraform Managed"
  cloud         = "azure"
  os            = "Linux"
  cost_center   = "n/a"
  hub_type      = "non-prod"
}

# DNS Zone
dns_zone = "azure.blox42.rocks"