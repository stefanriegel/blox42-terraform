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

# DNS-Zonen auflösen

data "bloxone_dns_auth_zones" "az_zone" {
  filters = {
    fqdn = "${var.dns_az_zone}.${var.dns_zone}"
  }
}

data "bloxone_dns_auth_zones" "aws_zone" {
  filters = {
    fqdn = "${var.dns_aws_zone}.${var.dns_zone}"
  }
}

data "bloxone_dns_auth_zones" "gcp_zone" {
  filters = {
    fqdn = "${var.dns_gcp_zone}.${var.dns_zone}"
  }
}

# A-Records anlegen

resource "bloxone_dns_a_record" "vm_dns_record_az" {
  name_in_zone = "${var.dns_a_record}-1"
  zone         = data.bloxone_dns_auth_zones.az_zone.results[0].id
  ttl          = 300
  comment      = "Terraform-managed Azure A record"

  rdata = {
    address = var.ip_az
  }
}

resource "bloxone_dns_a_record" "vm_dns_record_aws" {
  name_in_zone = "${var.dns_a_record}-2"
  zone         = data.bloxone_dns_auth_zones.aws_zone.results[0].id
  ttl          = 300
  comment      = "Terraform-managed AWS A record"

  rdata = {
    address = var.ip_aws
  }
}

resource "bloxone_dns_a_record" "vm_dns_record_gcp" {
  name_in_zone = "${var.dns_a_record}-3"
  zone         = data.bloxone_dns_auth_zones.gcp_zone.results[0].id
  ttl          = 300
  comment      = "Terraform-managed GCP A record"

  rdata = {
    address = var.ip_gcp
  }
}