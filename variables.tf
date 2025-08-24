

variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "ap-south-1"
  
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
  
}

variable "public_subnet_cidr" {
  description = "The CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "The CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"

}

variable "availability_zone" {
  description = "The availability zone for the subnet"
  type        = string
  default     = "ap-south-1a"
  
}

variable "key_name" {
  description = "EC2 key pair name to create/use"
  type        = string
  default     = "main-key"
}

variable "public_key_path" {
  description = "Path to your SSH public key"
  type        = string
  # Works on Linux/macOS/Windows (with Terraform's pathexpand)
  default     = "~/.ssh/id_rsa.pub"
}