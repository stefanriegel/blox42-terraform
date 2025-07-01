variable "csp_url" {
  description = "Infoblox CSP URL"
  type        = string
}

variable "api_key" {
  description = "Infoblox API Key"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "AWS Region"
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

variable "vm_vpc_name" {
  description = "VPC Name where VM will be deployed"
  type        = string
}

variable "vm_subnet_id" {
  description = "Subnet ID where VM will be deployed (leave null to create new VPC/subnet)"
  type        = string
  default     = null
}

variable "existing_infoblox_subnet_name" {
  description = "Name of existing Infoblox subnet to use (when using existing VPC)"
  type        = string
  default     = null
}

variable "subnet_cidr" {
  description = "Subnet size (CIDR e.g. /24)"
  type        = string
}

variable "availability_zone" {
  description = "AWS Availability Zone for the subnet"
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

variable "vm_name" {
  description = "Name of the EC2 Instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 Instance Type (e.g. t3.micro)"
  type        = string
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "SSH Key Pair name for EC2 access"
  type        = string
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