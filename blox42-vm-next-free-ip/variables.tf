variable "csp_url" {
  description = "Infoblox CSP URL"
  type        = string
}

variable "api_key" {
  description = "Infoblox API Key"
  type        = string
  sensitive   = true
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "region" {
  description = "Azure Region"
  type        = string
}

variable "resource_group" {
  description = "Azure Resource Group Name"
  type        = string
}

variable "vm_vnet_name" {
  description = "VNET Name where VM will be deployed"
  type        = string
}

variable "vm_subnet_name" {
  description = "Subnet Name where VM will be deployed"
  type        = string
}

variable "vm_name" {
  description = "Name of the Virtual Machine"
  type        = string
}

variable "vm_size" {
  description = "VM Size (e.g. Standard_B2s)"
  type        = string
}

variable "admin_username" {
  description = "Admin Username for the VM"
  type        = string
}

variable "admin_password" {
  description = "Admin Password for the VM"
  type        = string
  sensitive   = true
}

variable "vm_comment" {
  description = "Comment for Infoblox Entry"
  type        = string
}

variable "vm_tags" {
  description = "Tags for Infoblox Host"
  type        = map(string)
}

variable "dns_zone" {
  description = "DNS Zone for VM"
  type        = string
}