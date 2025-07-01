terraform {
  required_providers {
    bloxone = {
      source  = "infobloxopen/bloxone"
      version = ">= 0.7.2"
    }
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

provider "bloxone" {
  csp_url = var.csp_url
  api_key = var.api_key
}

provider "aws" {
  region = var.region
}

# Check if VPC/Subnet should be created or use existing
locals {
  create_vpc = var.vm_subnet_id == null  # Create VPC if no subnet ID provided
}

# Get Infoblox Address Block (only if creating VPC)
data "bloxone_ipam_address_blocks" "address_block_from_name" {
  count = local.create_vpc ? 1 : 0
  filters = {
    name = var.infoblox_address_block_name
  }
}

# Get next available subnet from Infoblox (only if creating VPC)
data "bloxone_ipam_next_available_subnets" "next_available_subnets" {
  count        = local.create_vpc ? 1 : 0
  id           = data.bloxone_ipam_address_blocks.address_block_from_name[0].results[0].id
  cidr         = tonumber(replace(var.subnet_cidr, "/", ""))
  subnet_count = 1
}

# Create AWS VPC (only if not using existing)
resource "aws_vpc" "vm_vpc" {
  count      = local.create_vpc ? 1 : 0
  cidr_block = "${replace(trimspace(data.bloxone_ipam_next_available_subnets.next_available_subnets[0].results[0]), "\"", "")}/${var.subnet_cidr}"
  tags = {
    Name = "${var.vpc_prefix}-${var.vm_vpc_name}"
  }
}

# Create AWS Subnet (only if not using existing)
resource "aws_subnet" "vm_subnet" {
  count             = local.create_vpc ? 1 : 0
  vpc_id            = aws_vpc.vm_vpc[0].id
  cidr_block        = "${replace(trimspace(data.bloxone_ipam_next_available_subnets.next_available_subnets[0].results[0]), "\"", "")}/${var.subnet_cidr}"
  availability_zone = var.availability_zone
  tags = {
    Name = "subnet-${aws_vpc.vm_vpc[0].tags["Name"]}"
  }
}

# Get existing subnet (if using existing)
data "aws_subnet" "existing_subnet" {
  count = local.create_vpc ? 0 : 1
  id    = var.vm_subnet_id
}

# Get existing VPC (if using existing subnet)
data "aws_vpc" "existing_vpc" {
  count = local.create_vpc ? 0 : 1
  id    = data.aws_subnet.existing_subnet[0].vpc_id
}

# Create Infoblox Subnet (only if creating new VPC)
resource "bloxone_ipam_subnet" "infoblox_subnet" {
  count   = local.create_vpc ? 1 : 0
  name    = "subnet-${aws_vpc.vm_vpc[0].tags["Name"]}"
  address = replace(trimspace(data.bloxone_ipam_next_available_subnets.next_available_subnets[0].results[0]), "\"", "")
  cidr    = var.subnet_cidr
  space   = data.bloxone_ipam_address_blocks.address_block_from_name[0].results[0].space
  comment = var.subnet_comment
  tags    = var.subnet_tags
}

# Get existing Infoblox subnet (if using existing VPC)
data "bloxone_ipam_subnets" "existing_infoblox_subnet" {
  count = local.create_vpc ? 0 : 1
  filters = {
    name = var.existing_infoblox_subnet_name
  }
}

# Reserve AWS reserved IP addresses (.1, .2, .3) in Infoblox
resource "bloxone_ipam_host" "aws_reserved_ips" {
  count = local.create_vpc ? 1 : 0
  
  name = "aws-reserved-${var.vm_vpc_name}"

  addresses = [
    {
      address = cidrhost(
        "${bloxone_ipam_subnet.infoblox_subnet[0].address}/${var.subnet_cidr}",
        1
      )
      space = bloxone_ipam_subnet.infoblox_subnet[0].space
    },
    {
      address = cidrhost(
        "${bloxone_ipam_subnet.infoblox_subnet[0].address}/${var.subnet_cidr}",
        2
      )
      space = bloxone_ipam_subnet.infoblox_subnet[0].space
    },
    {
      address = cidrhost(
        "${bloxone_ipam_subnet.infoblox_subnet[0].address}/${var.subnet_cidr}",
        3
      )
      space = bloxone_ipam_subnet.infoblox_subnet[0].space
    }
  ]

  comment = "AWS reserved addresses (.1=VPC router, .2=DNS, .3=Future use)"
  tags    = var.vm_tags

  depends_on = [bloxone_ipam_subnet.infoblox_subnet]
}

# Reserve IP from subnet
resource "bloxone_ipam_address" "vm_ip" {
  next_available_id = local.create_vpc ? bloxone_ipam_subnet.infoblox_subnet[0].id : data.bloxone_ipam_subnets.existing_infoblox_subnet[0].results[0].id
  space             = local.create_vpc ? bloxone_ipam_subnet.infoblox_subnet[0].space : data.bloxone_ipam_subnets.existing_infoblox_subnet[0].results[0].space
  comment           = "Terraform AWS EC2"
  tags              = var.vm_tags
  
  depends_on = [bloxone_ipam_host.aws_reserved_ips]
}

locals {
  vm_ip = bloxone_ipam_address.vm_ip.address
}

# Debug output for IP addresses
output "debug_vm_ip" {
  value = local.vm_ip
}

# Create AWS Network Interface
resource "aws_network_interface" "vm_nic" {
  subnet_id       = local.create_vpc ? aws_subnet.vm_subnet[0].id : data.aws_subnet.existing_subnet[0].id
  private_ips     = [local.vm_ip]
  security_groups = [aws_security_group.vm_sg.id]

  tags = {
    Name = "${var.vm_name}-nic"
  }
}

# Create Security Group
resource "aws_security_group" "vm_sg" {
  name_prefix = "${var.vm_name}-sg"
  vpc_id      = local.create_vpc ? aws_vpc.vm_vpc[0].id : data.aws_vpc.existing_vpc[0].id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.vm_name}-sg"
  }
}

# Create AWS EC2 Instance
resource "aws_instance" "vm" {
  ami           = var.ami_id
  instance_type = var.instance_type

  network_interface {
    network_interface_id = aws_network_interface.vm_nic.id
    device_index         = 0
  }

  key_name = var.key_name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from AWS EC2 - ${var.vm_name}</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name = var.vm_name
  }
}

# Register VM in Infoblox IPAM
resource "bloxone_ipam_host" "ipam_vm_registration" {
  name = var.vm_name

  addresses = [
    {
      address = local.vm_ip
      space   = local.create_vpc ? bloxone_ipam_subnet.infoblox_subnet[0].space : data.bloxone_ipam_subnets.existing_infoblox_subnet[0].results[0].space
    }
  ]

  comment = var.vm_comment
  tags    = var.vm_tags
}

# Get DNS Zone
data "bloxone_dns_auth_zones" "dns_zone" {
  filters = {
    fqdn = var.dns_zone
  }
}

# Create DNS A-Record for VM
resource "bloxone_dns_a_record" "vm_dns_record" {
  name_in_zone = var.vm_name
  zone         = try(data.bloxone_dns_auth_zones.dns_zone.results[0].id, null)
  ttl          = 300
  comment      = "Terraform-Managed AWS EC2"

  rdata = {
    address = local.vm_ip
  }

  depends_on = [bloxone_ipam_host.ipam_vm_registration]
}