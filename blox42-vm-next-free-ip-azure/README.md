# Infoblox Terraform Provider Demo - Azure VM

A demo showcasing how to use the Infoblox Terraform provider to automatically provision Azure Virtual Machines with dynamic IP address management.

## What it does

- Allocates next available IP address from Infoblox subnet
- Creates Azure Virtual Machine with the allocated IP address
- Creates Azure Network Interface with static IP allocation
- Registers VM hostname and IP in Infoblox IPAM
- Creates DNS A-record for the VM in Infoblox DNS

## Quick Setup

1. **Prerequisites**
   - Terraform >= 1.0
   - Azure CLI configured
   - Infoblox CSP account and API key

2. **Configure credentials**
   ```bash
   cat > terraform.auto.tfvars << EOF
   csp_url = "https://csp.eu.infoblox.com"
   api_key = "your-infoblox-api-key"
   subscription_id = "your-azure-subscription-id"
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
- `region`: Azure region (e.g., "West Europe")
- `resource_group`: Azure Resource Group name
- `vm_vnet_name`: Virtual Network name where VM will be deployed
- `vm_subnet_name`: Subnet name where VM will be deployed
- `vm_name`: Name of the Virtual Machine
- `vm_size`: VM Size (e.g., "Standard_B2s")
- `admin_username`: Admin username for the VM
- `admin_password`: Admin password for the VM
- `dns_zone`: DNS Zone for VM (e.g., "azure.blox42.rocks")

## Cleanup

```bash
terraform destroy
```

## Security Note

Never commit `terraform.auto.tfvars` to version control. Add it to `.gitignore`:
```bash
echo "terraform.auto.tfvars" >> .gitignore
``` 