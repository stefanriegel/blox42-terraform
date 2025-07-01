variable "csp_url" {
  description = "Infoblox CSP URL"
  type        = string
  sensitive   = true
}

variable "api_key" {
  description = "Infoblox API Key"
  type        = string
  sensitive   = true
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region for the VPC"
  type        = string
}

variable "infoblox_address_block_name" {
  description = "Name of the Address Block in Infoblox"
  type        = string
}

variable "vpc_prefix" {
  description = "Prefix for the VPC"
  type        = string
}

variable "vpcs" {
  description = "List of VPC names"
  type        = list(string)
}

variable "subnet_cidr" {
  description = "Subnet size (CIDR e.g. /24)"
  type        = string
}

variable "subnet_comment" {
  description = "Description for the Infoblox Subnet"
  type        = string
}

variable "subnet_tags" {
  description = "Tags for the subnet"
  type        = map(string)
} 