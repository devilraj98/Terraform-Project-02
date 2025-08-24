# Terraform AWS Infrastructure Project

This Terraform project creates a complete AWS infrastructure with VPC, public and private subnets, EC2 instances, and networking components for a secure and scalable environment.

## 🏗️ Infrastructure Overview

This project deploys the following AWS resources:

### Networking Components
- **VPC** with CIDR block `10.0.0.0/16`
- **Public Subnet** (`10.0.1.0/24`) in `ap-south-1a`
- **Private Subnet** (`10.0.2.0/24`) in `ap-south-1a`
- **Internet Gateway** for public internet access
- **NAT Gateway** for private subnet internet access
- **Route Tables** for both public and private subnets

### Compute Resources
- **Public EC2 Instance** (Ubuntu 20.04) in public subnet
- **Private EC2 Instance** (Ubuntu 20.04) in private subnet
- **Security Group** with SSH access (port 22)
- **Key Pair** for SSH authentication

### Architecture Diagram
```
Internet
    │
    ▼
┌─────────────────┐
│ Internet Gateway│
└─────────────────┘
    │
    ▼
┌─────────────────┐    ┌─────────────────┐
│  Public Subnet  │    │ Private Subnet  │
│  10.0.1.0/24    │    │  10.0.2.0/24    │
│                 │    │                 │
│ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │ Public EC2  │ │    │ │Private EC2  │ │
│ │ Instance    │ │    │ │ Instance    │ │
│ └─────────────┘ │    │ └─────────────┘ │
└─────────────────┘    └─────────────────┘
    │                        │
    ▼                        ▼
┌─────────────────┐    ┌─────────────────┐
│   NAT Gateway   │    │ Private Route   │
│                 │    │   Table         │
└─────────────────┘    └─────────────────┘
```

## 📋 Prerequisites

Before running this Terraform project, ensure you have:

1. **Terraform** installed (version >= 1.0)
   ```bash
   terraform --version
   ```

2. **AWS CLI** configured with appropriate credentials
   ```bash
   aws configure
   ```

3. **SSH Key Pair** for EC2 instance access
   ```bash
   # Generate SSH key if you don't have one
   ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa
   ```

4. **AWS Permissions** - Your AWS user/role needs permissions for:
   - VPC creation and management
   - EC2 instance creation
   - Security group management
   - Key pair management
   - NAT Gateway creation

## 🚀 Quick Start

### 1. Clone the Repository
```bash
git clone <your-repository-url>
cd Terraform-Project-02
```

### 2. Initialize Terraform
```bash
terraform init
```

### 3. Review the Plan
```bash
terraform plan
```

### 4. Apply the Infrastructure
```bash
terraform apply
```

### 5. Access Your Instances
After successful deployment, you can SSH to the public instance:
```bash
ssh -i ~/.ssh/id_rsa ubuntu@<public-ip>
```

## ⚙️ Configuration

### Variables
The project uses the following variables (defined in `variables.tf`):

| Variable | Description | Default Value |
|----------|-------------|---------------|
| `region` | AWS region | `ap-south-1` |
| `vpc_cidr` | VPC CIDR block | `10.0.0.0/16` |
| `public_subnet_cidr` | Public subnet CIDR | `10.0.1.0/24` |
| `private_subnet_cidr` | Private subnet CIDR | `10.0.2.0/24` |
| `availability_zone` | Availability zone | `ap-south-1a` |
| `key_name` | EC2 key pair name | `main-key` |
| `public_key_path` | SSH public key path | `~/.ssh/id_rsa.pub` |

### Customizing Configuration
Create a `terraform.tfvars` file to override default values:
```hcl
region = "us-east-1"
vpc_cidr = "172.16.0.0/16"
public_subnet_cidr = "172.16.1.0/24"
private_subnet_cidr = "172.16.2.0/24"
```

## 🔒 Security Considerations

### Current Security Settings
- **SSH Access**: Open to `0.0.0.0/0` (all IPs) - ⚠️ **For demo only**
- **Security Group**: Allows SSH (port 22) inbound, all traffic outbound
- **Private Instance**: No direct internet access (uses NAT Gateway)

### Recommended Security Improvements
1. **Restrict SSH Access**: Limit SSH access to specific IP ranges
2. **Additional Security Groups**: Create separate security groups for different application tiers
3. **VPC Flow Logs**: Enable for network monitoring
4. **CloudWatch Logs**: Enable for instance monitoring

### Example Secure SSH Configuration
```hcl
ingress {
  description = "SSH access from office"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["YOUR_OFFICE_IP/32"]  # Replace with your IP
}
```

## 📊 Outputs

The project provides the following outputs:
- Public EC2 instance public IP
- Private EC2 instance private IP
- VPC ID
- Subnet IDs

## 🧹 Cleanup

To destroy all created resources:
```bash
terraform destroy
```

**⚠️ Warning**: This will permanently delete all AWS resources created by this project.

## 📁 Project Structure

```
Terraform-Project-02/
├── main.tf              # Main infrastructure configuration
├── variables.tf         # Variable definitions
├── provider.tf          # AWS provider configuration
├── .terraform.lock.hcl  # Provider version lock file
├── .gitignore          # Git ignore rules
└── README.md           # This file
```

## 🔧 Troubleshooting

### Common Issues

1. **SSH Key Not Found**
   - Ensure your SSH public key exists at `~/.ssh/id_rsa.pub`
   - Or update the `public_key_path` variable

2. **AWS Credentials**
   - Verify AWS credentials are configured: `aws sts get-caller-identity`
   - Check IAM permissions for required services

3. **NAT Gateway Costs**
   - NAT Gateways incur hourly charges (~$0.045/hour)
   - Consider using NAT Instance for cost optimization in non-production

4. **AMI Not Found**
   - The project uses Ubuntu 20.04 AMI
   - Ensure the AMI is available in your selected region

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `terraform plan`
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For issues and questions:
- Create an issue in the GitHub repository
- Check the troubleshooting section above
- Review Terraform and AWS documentation

---

**Note**: This is a demonstration project. For production use, implement proper security measures, backup strategies, and monitoring solutions.
