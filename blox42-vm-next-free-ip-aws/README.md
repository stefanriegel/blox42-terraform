# Infoblox Terraform Provider Demo - AWS EC2

A demo showcasing how to use the Infoblox Terraform provider to automatically provision AWS EC2 instances with dynamic IP address management.

## What it does

- **Option 1**: Creates new VPC and subnet with Infoblox address allocation
- **Option 2**: Uses existing VPC/subnet from the `blox42-vpc-next-free-subnet-aws` project
- Allocates next available IP address from Infoblox subnet
- Creates AWS EC2 instance with the allocated IP address
- Creates AWS Network Interface with static IP allocation
- Registers VM hostname and IP in Infoblox IPAM
- Creates DNS A-record for the VM in Infoblox DNS

## Quick Setup

1. **Prerequisites**
   - Terraform >= 1.0
   - AWS CLI configured
   - Infoblox CSP account and API key
   - Infoblox address block configured (see Configuration section)
   - For Option 2: `blox42-vpc-next-free-subnet-aws` project deployed first

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
- `vm_subnet_id`: Subnet ID (null = create new, "subnet-xxx" = use existing)
- `existing_infoblox_subnet_name`: Name of existing Infoblox subnet (for Option 2)
- `vpc_prefix`: Prefix for the VPC (for new VPC or existing VPC lookup)
- `vm_vpc_name`: VPC name (for new VPC or existing VPC lookup)
- `subnet_cidr`: Subnet size (e.g., "24") (for new VPC)
- `availability_zone`: AWS Availability Zone (e.g., "eu-central-1a") (for new VPC)
- `vm_name`: Name of the EC2 instance
- `instance_type`: EC2 instance type (e.g., "t3.nano")
- `ami_id`: AMI ID for the EC2 instance (region-specific)
- `key_name`: SSH key pair name for EC2 access
- `dns_zone`: DNS Zone for VM (e.g., "aws.blox42.rocks")

**AMI ID Notes:**
- The AMI ID is region-specific and must be valid for your chosen region
- For Amazon Linux 2 in eu-central-1 (Frankfurt): `ami-0c55b159cbfafe1f0`
- To find the latest AMI for your region:
  ```bash
  aws ec2 describe-images --owners amazon --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" --query 'Images[*].[ImageId,CreationDate]' --region eu-central-1 --output text | sort -k2 -r | head -1
  ```

**Important**: 
- For Option 1: The `infoblox_address_block_name` must reference an existing address block in your Infoblox instance
- For Option 2: Make sure the `blox42-vpc-next-free-subnet-aws` project is deployed first

## Cleanup

```bash
terraform destroy
```

## Security Note

Never commit `terraform.auto.tfvars` to version control. Add it to `.gitignore`:
```bash
echo "terraform.auto.tfvars" >> .gitignore
``` 