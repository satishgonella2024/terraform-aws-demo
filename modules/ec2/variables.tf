# AMI for instances
variable "ami" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0c104f6f4a5d9d1d5"  # ✅ Correct AMI ID
}

# Instance type per environment
variable "instance_type" {
  description = "EC2 instance types per environment"
  type        = map(string)
  default = {
    dev     = "t2.micro"
    staging = "t3.small"
    prod    = "t3.medium"
  }
}

# Public Subnet IDs per workspace
variable "public_subnet_ids" {
  description = "Public subnet IDs per environment"
  type        = map(list(string))
}

# Private Subnet IDs per workspace
variable "private_subnet_ids" {
  description = "Private subnet IDs per environment"
  type        = map(list(string))
}

# SSH Key
variable "ssh_key" {
  description = "SSH Key Name"
  type        = string
}

# Security Group ID
variable "security_group" {
  description = "Security Group ID"
  type        = string
}