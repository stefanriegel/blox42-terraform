# Infoblox Terraform Provider Demo - Multi-Cloud DNS - AWS, Azure and GCP

A demo showcasing how to use the Infoblox Terraform provider to manage DNS records across multiple cloud providers (Azure, AWS, GCP) with centralized DNS management.

## What it does

- Creates DNS A-records for multiple cloud providers in a single configuration
- Manages Azure, AWS, and GCP subzones under a common root DNS zone
- Establishes consistent DNS naming across cloud environments
- Provides centralized DNS management through Infoblox

## Quick Setup

1. **Prerequisites**
   - Terraform >= 1.0
   - Infoblox CSP account and API key
   - DNS zones configured in Infoblox

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
- `dns_zone`: Root DNS zone (e.g., "blox42.rocks")
- `dns_az_zone`: Azure subzone (e.g., "azure")
- `dns_aws_zone`: AWS subzone (e.g., "aws")
- `dns_gcp_zone`: GCP subzone (e.g., "gcp")
- `dns_a_record`: Name prefix for A records (e.g., "vm-multi-cloud")
- `ip_az`: IP address for Azure VM
- `ip_aws`: IP address for AWS VM
- `ip_gcp`: IP address for GCP VM

## Cleanup

```bash
terraform destroy
```

## Security Note

Never commit `terraform.auto.tfvars` to version control. Add it to `.gitignore`:
```bash
echo "terraform.auto.tfvars" >> .gitignore
``` 