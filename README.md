# Infoblox Terraform Provider Demo Collection

A comprehensive collection of Terraform demos showcasing how to use the Infoblox Terraform provider for automated IP address management and DNS configuration across multiple cloud providers.

## What it does

This repository contains multiple Terraform modules that demonstrate:

- **Dynamic IP address allocation** from Infoblox address blocks
- **Multi-cloud infrastructure provisioning** (AWS, Azure, GCP)
- **Centralized DNS management** across cloud environments
- **Automated subnet and VPC creation** with Infoblox integration
- **Virtual Machine provisioning** with dynamic IP assignment

## Available Modules

**blox42-dns-multi-cloud** - Multi-Cloud DNS Management
- Creates DNS A-records for multiple cloud providers in a single configuration
- Manages Azure, AWS, and GCP subzones under a common root DNS zone
- Establishes consistent DNS naming across cloud environments
- Provides centralized DNS management through Infoblox

**blox42-vm-next-free-ip-azure** - Azure VM with Dynamic IP
- Allocates next available IP address from Infoblox subnet
- Creates Azure Virtual Machine with the allocated IP address
- Creates Azure Network Interface with static IP allocation
- Registers VM hostname and IP in Infoblox IPAM
- Creates DNS A-record for the VM in Infoblox DNS

**blox42-vnet-next-free-subnet-azure** - Azure VNet Provisioning
- Allocates next available subnets from Infoblox address blocks
- Creates Azure Virtual Networks and subnets with the allocated CIDR ranges
- Reserves critical IP addresses (.1, .2, .3) for Azure infrastructure
- Synchronizes subnet information between Azure and Infoblox

**blox42-vpc-next-free-subnet-aws** - AWS VPC Provisioning
- Allocates next available subnets from Infoblox address blocks
- Creates AWS VPCs and subnets with the allocated CIDR ranges
- Reserves critical IP addresses (.1, .2, .3) for AWS infrastructure
- Synchronizes subnet information between AWS and Infoblox

**blox42-vpc-next-free-subnet-gcp** - GCP VPC Provisioning
- Allocates next available subnets from Infoblox address blocks
- Creates GCP VPCs and subnets with the allocated CIDR ranges
- Reserves critical IP addresses (.1, .2, .3) for GCP infrastructure
- Synchronizes subnet information between GCP and Infoblox

## Quick Setup

1. **Prerequisites**
   - Terraform >= 1.0
   - Cloud provider CLI tools (AWS CLI, Azure CLI)
   - Infoblox CSP account and API key

2. **Choose a module**
   ```bash
   # Navigate to the desired module directory
   cd blox42-vm-next-free-ip
   # or
   cd blox42-dns-multi-cloud
   # or
   cd blox42-vnet-next-free-subnet
   # or
   cd blox42-vpc-next-free-subnet
   # or
   cd blox42-vpc-next-free-subnet-gcp
   ```

3. **Configure credentials**
   ```bash
   cat > terraform.auto.tfvars << EOF
   csp_url = "https://csp.eu.infoblox.com"
   api_key = "your-infoblox-api-key"
   subscription_id = "your-azure-subscription-id"  # For Azure modules
   EOF
   ```

4. **Customize settings**
   ```bash
   # Edit terraform.tfvars with your configuration
   nano terraform.tfvars
   ```

5. **Deploy**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Module Configuration

Each module has its own `terraform.tfvars` file with example configurations:

- **blox42-dns-multi-cloud**: DNS zones, subzones, and IP addresses for multi-cloud setup
- **blox42-vm-next-free-ip**: VM configuration, network settings, and DNS zone
- **blox42-vnet-next-free-subnet**: Azure VNet and subnet configuration
- **blox42-vpc-next-free-subnet**: AWS VPC and subnet configuration
- **blox42-vpc-next-free-subnet-gcp**: GCP VPC and subnet configuration

## Cleanup

```bash
# Navigate to the module directory
cd <module-name>
terraform destroy
```

## Security Note

Never commit `terraform.auto.tfvars` to version control. These files contain sensitive information like API keys and credentials. The `.gitignore` file is already configured to exclude these files.

## Project Structure

```
lab/
├── blox42-dns-multi-cloud/     # Multi-cloud DNS management
├── blox42-vm-next-free-ip/     # Azure VM with dynamic IP
├── blox42-vnet-next-free-subnet/ # Azure VNet provisioning
├── blox42-vpc-next-free-subnet/  # AWS VPC provisioning
├── blox42-vpc-next-free-subnet-gcp/ # GCP VPC provisioning
├── .gitignore                   # Git ignore patterns
└── README.md                    # This file
```

## Contributing

Each module is self-contained and can be used independently. When adding new modules, please follow the established structure and include a comprehensive README.md file. 