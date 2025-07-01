# Infoblox Terraform Provider Demo

A demo showcasing how to use the Infoblox Terraform provider to automatically provision AWS VPCs and subnets with dynamic IP address management.

## What it does

- Allocates next available subnets from Infoblox address blocks
- Creates AWS VPCs and subnets with the allocated CIDR ranges
- Reserves critical IP addresses (.1, .2, .3) for AWS infrastructure
- Synchronizes subnet information between AWS and Infoblox

## Quick Setup

1. **Prerequisites**
   - Terraform >= 1.0
   - AWS CLI configured
   - Infoblox CSP account and API key

2. **Configure credentials**
   ```bash
   cat > terraform.auto.tfvars << EOF
   csp_url = "https://csp.eu.infoblox.com"
   api_key = "your-infoblox-api-key"
   EOF
   ```

3. **Customize settings**
   ```bash
   # Edit terraform.tfvars with your configuration
   nano terraform.tfvars
   ```

4. **Deploy**
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Configuration

Key variables in `terraform.tfvars`:
- `region`: AWS region (e.g., "eu-central-1")
- `availability_zone`: AWS AZ (e.g., "eu-central-1a")
- `infoblox_address_block_name`: Name of your Infoblox address block
- `vpcs`: List of VPC names to create
- `subnet_cidr`: Subnet size (e.g., "24")

## Cleanup

```bash
terraform destroy
```

## Security Note

Never commit `terraform.auto.tfvars` to version control. Add it to `.gitignore`:
```bash
echo "terraform.auto.tfvars" >> .gitignore
``` 