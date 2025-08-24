
#------------------------------
# Create a VPC
#-----------------------------
resource "aws_vpc" "mainvpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "Project-VPC"
  }
}

#------------------------------
# Create a Public Subnet
#-----------------------------

resource "aws_subnet" "PublicSubnet" {
    vpc_id = aws_vpc.mainvpc.id
    cidr_block = var.public_subnet_cidr
    map_public_ip_on_launch = true
    availability_zone = var.availability_zone

    tags = {
        Name = "public-subnet-01"
    }
  
}
#------------------------------
# Create an private Subnet
#-----------------------------

resource "aws_subnet" "privateSubnet" {
    vpc_id = aws_vpc.mainvpc.id
    cidr_block = var.private_subnet_cidr
    map_public_ip_on_launch = false
    availability_zone = var.availability_zone

    tags = {
        Name = "private-subnet-01"
    }

}

#------------------------------
# Create an Public Route table
#-----------------------------

resource "aws_route_table" "Public-RT" {
  vpc_id = aws_vpc.mainvpc.id
    
    tags = {
        Name = "Public-RT"
    }

}

#------------------------------
# Create an Private Route table
#-----------------------------

resource "aws_route_table" "Private-RT" {
  vpc_id = aws_vpc.mainvpc.id
    
    tags = {
        Name = "Private-RT"
    }

}   

#------------------------------
# create route table association for public subnet
#-----------------------------

resource "aws_route_table_association" "Public-RT-assoc" {
    subnet_id = aws_subnet.PublicSubnet.id
    route_table_id = aws_route_table.Public-RT.id
}

#------------------------------
# create route table association for private subnet
#-----------------------------  

resource "aws_route_table_association" "Private-RT-assoc" {
    subnet_id = aws_subnet.privateSubnet.id
    route_table_id = aws_route_table.Private-RT.id
}

#------------------------------
# Create an Internet Gateway       
#-----------------------------

resource "aws_internet_gateway" "igw" {
   vpc_id = aws_vpc.mainvpc.id

    tags = {
        Name = "My-Project-IGW"
    }
}

#------------------------------
# Create a route to the Internet Gateway in the Public Route Table
#-----------------------------

resource "aws_route" "public_internet_access" {
    route_table_id = aws_route_table.Public-RT.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  
}

#------------------------------
# Create a Elastic IP for the NAT Gateway
#-----------------------------

resource "aws_eip" "eip-nk" {
  domain = "vpc"
  tags = {
    Name = "NAT-EIP" 
    
  }
}

#------------------------------
# Create a NAT Gateway in the Public Subnet
#-----------------------------

resource "aws_nat_gateway" "example" {
  allocation_id = aws_eip.eip-nk.id
  subnet_id     = aws_subnet.PublicSubnet.id

  tags = {
    Name = "NAT-Project"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.igw]
}

#------------------------------
# create a ec2 instance in public subnet
#-----------------------------


# ----------------------
# Security Group for Bastion Host
# ----------------------
resource "aws_security_group" "bastion_sg" {
  vpc_id = aws_vpc.mainvpc.id
  name   = "bastion-sg"

  ingress {
    description = "SSH access to bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ⚠️ Restrict to your IP in production
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sg"
  }
}

# ----------------------
# Security Group for Private Instances
# ----------------------
resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.mainvpc.id
  name   = "private-sg"

  ingress {
    description = "SSH access from bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "private-sg"
  }
}

# ----------------------
# Security Group for Public Instances (legacy)
# ----------------------
resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.mainvpc.id
  name   = "ec2-sg"

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ⚠️ For demo only, restrict in real usage
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-sg"
  }
}

# ----------------------
# Key Pair (optional)
# ----------------------
resource "aws_key_pair" "main_key" {
  key_name   = "weekend-batch"
  public_key = "dummy-key-for-imported-resource"
  
  lifecycle {
    ignore_changes = [public_key]
  }
}

# ----------------------
# Bastion Host (Jump Server)
# ----------------------
resource "aws_instance" "bastion_host" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.PublicSubnet.id
  vpc_security_group_ids      = [aws_security_group.bastion_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.main_key.key_name

  user_data = <<-EOF
              #!/bin/bash
              # Update system
              apt-get update
              apt-get install -y openssh-server
              
              # Configure SSH for better security
              sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
              sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
              systemctl restart ssh
              EOF

  tags = {
    Name = "bastion-host"
  }
}

# ----------------------
# Public EC2 Instance
# ----------------------
resource "aws_instance" "public_ec2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.PublicSubnet.id
  vpc_security_group_ids      = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true
  key_name                    = aws_key_pair.main_key.key_name

  tags = {
    Name = "public-ec2"
  }
}

# ----------------------
# Private EC2 Instance
# ----------------------
resource "aws_instance" "private_ec2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.privateSubnet.id
  vpc_security_group_ids      = [aws_security_group.private_sg.id]
  associate_public_ip_address = false
  key_name                    = aws_key_pair.main_key.key_name

  tags = {
    Name = "private-ec2"
  }
}

# ----------------------
# Fetch Latest Ubuntu AMI
# ----------------------
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ----------------------
# Outputs
# ----------------------
output "bastion_host_public_ip" {
  description = "Public IP of the bastion host"
  value       = aws_instance.bastion_host.public_ip
}

output "private_instance_private_ip" {
  description = "Private IP of the private instance"
  value       = aws_instance.private_ec2.private_ip
}

output "public_instance_public_ip" {
  description = "Public IP of the public instance"
  value       = aws_instance.public_ec2.public_ip
}

output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.mainvpc.id
}

output "bastion_ssh_command" {
  description = "SSH command to connect to bastion host"
  value       = "ssh -i ~/.ssh/id_rsa ubuntu@${aws_instance.bastion_host.public_ip}"
}

output "private_instance_ssh_command" {
  description = "SSH command to connect to private instance via bastion"
  value       = "ssh -i ~/.ssh/id_rsa -J ubuntu@${aws_instance.bastion_host.public_ip} ubuntu@${aws_instance.private_ec2.private_ip}"
}
