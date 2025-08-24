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
- **Bastion Host** (Ubuntu 20.04) - Secure jump server in public subnet
- **Public EC2 Instance** (Ubuntu 20.04) in public subnet
- **Private EC2 Instance** (Ubuntu 20.04) in private subnet
- **Security Groups** with proper access controls
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
│ │  Bastion    │ │    │ │Private EC2  │ │
│ │   Host      │ │    │ │ Instance    │ │
│ │ (Jump Box)  │ │    │ │             │ │
│ └─────────────┘ │    │ └─────────────┘ │
│                 │    │                 │
│ ┌─────────────┐ │    │                 │
│ │ Public EC2  │ │    │                 │
│ │ Instance    │ │    │                 │
│ └─────────────┘ │    │                 │
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
After successful deployment, you can access your instances:

**Connect to Bastion Host:**
```bash
ssh -i ~/.ssh/id_rsa ubuntu@<bastion-public-ip>
```

**Connect to Private Instance via Bastion:**
```bash
ssh -i ~/.ssh/id_rsa -J ubuntu@<bastion-public-ip> ubuntu@<private-instance-ip>
```

**Connect to Public Instance (direct):**
```bash
ssh -i ~/.ssh/id_rsa ubuntu@<public-ip>
```

**Or use Terraform outputs for ready-to-use commands:**
```bash
terraform output bastion_ssh_command
terraform output private_instance_ssh_command
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
- **Bastion Host**: SSH access from `0.0.0.0/0` (all IPs) - ⚠️ **Restrict in production**
- **Private Instances**: SSH access only from bastion host security group
- **Public Instances**: SSH access from `0.0.0.0/0` (all IPs) - ⚠️ **For demo only**
- **Security Groups**: Properly segregated with bastion-only access to private instances
- **Private Instance**: No direct internet access (uses NAT Gateway)

### Recommended Security Improvements
1. **Restrict Bastion Access**: Limit bastion SSH access to specific IP ranges
2. **Bastion Host Hardening**: 
   - Use AWS Systems Manager Session Manager instead of SSH
   - Implement multi-factor authentication
   - Regular security updates and monitoring
3. **Additional Security Groups**: Create separate security groups for different application tiers
4. **VPC Flow Logs**: Enable for network monitoring
5. **CloudWatch Logs**: Enable for instance monitoring
6. **Bastion Host Monitoring**: Set up alerts for failed login attempts

### Example Secure SSH Configuration
```hcl
# Bastion Host Security Group
ingress {
  description = "SSH access from office"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["YOUR_OFFICE_IP/32"]  # Replace with your IP
}

# Private Instance Security Group
ingress {
  description = "SSH access from bastion only"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  security_groups = [aws_security_group.bastion_sg.id]
}
```

## 📊 Outputs

The project provides the following outputs:
- **Bastion Host**: Public IP and SSH command
- **Private Instance**: Private IP and SSH command via bastion
- **Public Instance**: Public IP
- **VPC ID**: For reference and further configuration
- **Ready-to-use SSH commands**: Copy-paste commands for easy access

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

2. **Cannot Connect to Private Instance**
   - Verify you're connecting through the bastion host
   - Check that the bastion host is running and accessible
   - Ensure your SSH key is properly configured on both bastion and private instance

3. **Bastion Host Connection Issues**
   - Verify the bastion host security group allows SSH from your IP
   - Check that the bastion host has finished initializing (user data script)
   - Ensure the SSH service is running on the bastion host

4. **AWS Credentials**
   - Verify AWS credentials are configured: `aws sts get-caller-identity`
   - Check IAM permissions for required services

5. **NAT Gateway Costs**
   - NAT Gateways incur hourly charges (~$0.045/hour)
   - Consider using NAT Instance for cost optimization in non-production

6. **AMI Not Found**
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

## 🏗️ Bastion Host Architecture

This project implements a **bastion host (jump server)** pattern for secure access to private instances:

### **How It Works:**
1. **Bastion Host**: Single point of entry in the public subnet
2. **Private Instances**: Only accessible through the bastion host
3. **Security Groups**: Properly configured to allow bastion → private instance communication
4. **SSH Proxy**: Use SSH jump host feature for seamless access

### **Benefits:**
- ✅ **Reduced Attack Surface**: Only one public entry point
- ✅ **Centralized Access Control**: All access goes through bastion
- ✅ **Audit Trail**: All access can be logged and monitored
- ✅ **Easier Management**: Single point for security updates

---

**Note**: This is a demonstration project. For production use, implement proper security measures, backup strategies, and monitoring solutions. Consider using AWS Systems Manager Session Manager as an alternative to traditional bastion hosts.
