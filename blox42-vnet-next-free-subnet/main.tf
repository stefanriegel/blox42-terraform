terraform {
  required_providers {
    bloxone = {
      source  = "infobloxopen/bloxone"
      version = ">= 0.7.2"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
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

locals {
  prefix       = var.vnet_prefix
  subnet_count = length(var.vnets)
}

# Hole Address Block aus Infoblox
data "bloxone_ipam_address_blocks" "example_by_attribute" {
  filters = {
    name = var.infoblox_address_block_name
  }
}

# Hole nächste freie Subnetze aus Infoblox
data "bloxone_ipam_next_available_subnets" "example_tf_subs" {
  id           = data.bloxone_ipam_address_blocks.example_by_attribute.results.0.id
  cidr         = tonumber(replace(var.subnet_cidr, "/", ""))
  subnet_count = local.subnet_count
}

# Erstelle Virtual Networks
resource "azurerm_virtual_network" "vnets" {
  for_each            = toset(var.vnets)
  name                = "${local.prefix}-${each.value}"  
  location            = var.region
  resource_group_name = var.resource_group
  address_space       = ["${replace(trimspace(data.bloxone_ipam_next_available_subnets.example_tf_subs.results[index(var.vnets, each.value)]), "\"", "")}/${var.subnet_cidr}"]
}

# Erstelle Subnets in Azure
resource "azurerm_subnet" "vnets_subnets" {
  for_each             = toset(var.vnets)
  name                 = "subnet-${azurerm_virtual_network.vnets[each.value].name}"  
  resource_group_name  = var.resource_group
  virtual_network_name = azurerm_virtual_network.vnets[each.value].name
  address_prefixes     = ["${replace(trimspace(data.bloxone_ipam_next_available_subnets.example_tf_subs.results[index(var.vnets, each.value)]), "\"", "")}/${var.subnet_cidr}"]
}

# Wartezeit für Subnetz-Synchronisation
resource "time_sleep" "wait_for_subnet" {
  depends_on      = [azurerm_subnet.vnets_subnets]
  create_duration = "5s"
}

# Registriere Subnets in Infoblox mit Azure-konformer Namensgebung
resource "bloxone_ipam_subnet" "infoblox_subnets" {
  for_each = toset(var.vnets)

  name    = "subnet-${azurerm_virtual_network.vnets[each.value].name}"
  address = replace(trimspace(data.bloxone_ipam_next_available_subnets.example_tf_subs.results[index(var.vnets, each.value)]), "\"", "")
  cidr    = var.subnet_cidr
  space   = data.bloxone_ipam_address_blocks.example_by_attribute.results.0.space
  comment = var.subnet_comment

  tags = var.subnet_tags
}

# Wartezeit für Infoblox-Synchronisation
resource "time_sleep" "wait_for_infoblox" {
  depends_on      = [bloxone_ipam_subnet.infoblox_subnets]
  create_duration = "5s"
}

# Reserviere vordefinierte IPs in Infoblox für jedes Subnetz
resource "bloxone_ipam_host" "infoblox_reserved_ips" {
  for_each = toset(var.vnets)

  depends_on = [time_sleep.wait_for_infoblox]  # Sicherstellen, dass das Subnetz existiert

  name = "reserved-ips-subnet-${azurerm_virtual_network.vnets[each.value].name}"

  addresses = [
    {
      address = cidrhost("${bloxone_ipam_subnet.infoblox_subnets[each.value].address}/${var.subnet_cidr}", 1)
      space   = data.bloxone_ipam_address_blocks.example_by_attribute.results.0.space
      comment = "Default Gateway"
    },
    {
      address = cidrhost("${bloxone_ipam_subnet.infoblox_subnets[each.value].address}/${var.subnet_cidr}", 2)
      space   = data.bloxone_ipam_address_blocks.example_by_attribute.results.0.space
      comment = "Azure Reserved IP"
    },
    {
      address = cidrhost("${bloxone_ipam_subnet.infoblox_subnets[each.value].address}/${var.subnet_cidr}", 3)
      space   = data.bloxone_ipam_address_blocks.example_by_attribute.results.0.space
      comment = "Azure Reserved IP"
    }
  ]

  tags = var.subnet_tags
}