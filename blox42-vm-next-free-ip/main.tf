terraform {
  required_providers {
    bloxone = {
      source  = "infobloxopen/bloxone"
      version = ">= 0.7.2"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.117.1"
    }
  }
}

provider "bloxone" {
  csp_url = var.csp_url
  api_key = var.api_key
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# Abrufen des Azure-Subnetzes
data "azurerm_subnet" "vm_subnet" {
  name                 = var.vm_subnet_name
  virtual_network_name = var.vm_vnet_name
  resource_group_name  = var.resource_group
}

# Infoblox-Subnetz abrufen
data "bloxone_ipam_subnets" "infoblox_subnet" {
  filters = {
    name = "subnet-${var.vm_vnet_name}"
  }
}

# IP aus Subnetz reservieren
resource "bloxone_ipam_address" "vm_ip" {
  next_available_id = data.bloxone_ipam_subnets.infoblox_subnet.results[0].id
  space             = data.bloxone_ipam_subnets.infoblox_subnet.results[0].space
  comment           = "Terraform Azure VM"
  tags              = var.vm_tags
}

locals {
  vm_ip = bloxone_ipam_address.vm_ip.address
}

# Debug-Output für IP-Adressen
output "debug_vm_ip" {
  value = local.vm_ip
}

# Erstellen der Azure-Netzwerkschnittstelle
resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.vm_name}-nic"
  location            = var.region
  resource_group_name = var.resource_group

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.vm_subnet.id
    private_ip_address_allocation = "Static"
    private_ip_address            = local.vm_ip
  }
}

# Azure Virtual Machine erstellen
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = var.vm_name
  location              = var.region
  resource_group_name   = var.resource_group
  size                  = var.vm_size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.vm_nic.id
  ]

os_disk {
  caching              = "ReadWrite"
  storage_account_type = "Standard_LRS"
}

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18_04-lts-gen2"
    version   = "latest"
  }

  tags = var.vm_tags
}

# VM in Infoblox registrieren
resource "bloxone_ipam_host" "ipam_vm_registration" {
  name = var.vm_name

  addresses = [
    {
      address = local.vm_ip
      space   = data.bloxone_ipam_subnets.infoblox_subnet.results[0].space
    }
  ]

  comment = var.vm_comment
  tags    = var.vm_tags
}

# DNS-Zone abrufen
data "bloxone_dns_auth_zones" "dns_zone" {
  filters = {
    fqdn = var.dns_zone
  }
}

# DNS-A-Record für VM erstellen
resource "bloxone_dns_a_record" "vm_dns_record" {
  name_in_zone = var.vm_name
  zone         = try(data.bloxone_dns_auth_zones.dns_zone.results[0].id, null)
  ttl          = 300
  comment      = "Terraform-Managed Azure VM"

  rdata = {
    address = local.vm_ip
  }

  depends_on = [bloxone_ipam_host.ipam_vm_registration]
}