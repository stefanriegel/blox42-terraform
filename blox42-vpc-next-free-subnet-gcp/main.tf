terraform {
  required_providers {
    bloxone = {
      source  = "infobloxopen/bloxone"
      version = ">= 0.7.2"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 4.0.0"
    }
  }
}

provider "bloxone" {
  csp_url = var.csp_url
  api_key = var.api_key
}

provider "google" {
  project = var.project_id
  region  = var.region
}

locals {
  prefix       = var.vpc_prefix
  subnet_count = length(var.vpcs)

  reserved_ip_entries = merge(
    {
      for vpc in var.vpcs :
      "${vpc}-1" => {
        vpc     = vpc
        offset  = 1
        comment = "reserved GCP Default Gateway"
      }
    },
    {
      for vpc in var.vpcs :
      "${vpc}-2" => {
        vpc     = vpc
        offset  = 2
        comment = "reserved GCP DNS server"
      }
    },
    {
      for vpc in var.vpcs :
      "${vpc}-3" => {
        vpc     = vpc
        offset  = 3
        comment = "reserved by GCP for future use"
      }
    }
  )
}

data "bloxone_ipam_address_blocks" "address_block_from_name" {
  filters = {
    name = var.infoblox_address_block_name
  }
}

data "bloxone_ipam_next_available_subnets" "next_available_subnets" {
  id           = data.bloxone_ipam_address_blocks.address_block_from_name.results[0].id
  cidr         = tonumber(replace(var.subnet_cidr, "/", ""))
  subnet_count = local.subnet_count
}

resource "google_compute_network" "vpcs" {
  for_each                = toset(var.vpcs)
  name                    = "${local.prefix}-${each.value}"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

resource "google_compute_subnetwork" "vpcs_subnets" {
  for_each      = toset(var.vpcs)
  name          = "subnet-${google_compute_network.vpcs[each.value].name}"
  ip_cidr_range = "${replace(trimspace(data.bloxone_ipam_next_available_subnets.next_available_subnets.results[index(var.vpcs, each.value)]), "\"", "")}/${var.subnet_cidr}"
  network       = google_compute_network.vpcs[each.value].id
  region        = var.region
}

resource "time_sleep" "wait_for_subnet" {
  depends_on      = [google_compute_subnetwork.vpcs_subnets]
  create_duration = "5s"
}

resource "bloxone_ipam_subnet" "infoblox_subnets" {
  for_each = toset(var.vpcs)

  name    = "subnet-${google_compute_network.vpcs[each.value].name}"
  address = replace(trimspace(data.bloxone_ipam_next_available_subnets.next_available_subnets.results[index(var.vpcs, each.value)]), "\"", "")
  cidr    = var.subnet_cidr
  space   = data.bloxone_ipam_address_blocks.address_block_from_name.results[0].space
  comment = var.subnet_comment

  tags = var.subnet_tags
}

resource "time_sleep" "wait_for_infoblox" {
  depends_on      = [bloxone_ipam_subnet.infoblox_subnets]
  create_duration = "5s"
}

# Reserve .1, .2, .3 as "used" by host objects
resource "bloxone_ipam_host" "reserved_ips" {
  for_each = local.reserved_ip_entries

  name = "reserved-${each.key}"

  addresses = [
    {
      address = cidrhost(
        "${bloxone_ipam_subnet.infoblox_subnets[each.value.vpc].address}/${var.subnet_cidr}",
        each.value.offset
      )
      space = data.bloxone_ipam_address_blocks.address_block_from_name.results[0].space
    }
  ]

  comment = each.value.comment
  tags    = var.subnet_tags

  depends_on = [time_sleep.wait_for_infoblox]
} 