variable "dns_zone" {
  description = "Root DNS zone"
  type        = string
}

variable "dns_az_zone" {
  description = "Azure subzone"
  type        = string
}

variable "dns_aws_zone" {
  description = "AWS subzone"
  type        = string
}

variable "dns_gcp_zone" {
  description = "GCP subzone"
  type        = string
}

variable "dns_a_record" {
  description = "Name of the A record (prefix)"
  type        = string
}

variable "ip_az" {
  description = "IP address for Azure"
  type        = string
}

variable "ip_aws" {
  description = "IP address for AWS"
  type        = string
}

variable "ip_gcp" {
  description = "IP address for GCP"
  type        = string
}

variable "csp_url" {
  description = "CSP URL for Infoblox"
  type        = string
  sensitive   = true
}

variable "api_key" {
  description = "API Key for Infoblox"
  type        = string
  sensitive   = true
}
