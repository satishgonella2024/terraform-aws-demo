# VPC Configuration
variable "vpc_cidr" {
  description = "VPC CIDR block per workspace"
  type        = map(string)
  default = {
    dev     = "10.0.0.0/24"
    staging = "10.0.0.0/22"
    prod    = "10.0.0.0/16"
  }
}

variable "vpc_name" {
  description = "VPC Name"
  type        = string
  default     = "terraform-vpc"
}

# Subnet Count Configuration
variable "subnet_count" {
  description = "Number of subnets per environment"
  type        = map(number)
  default = {
    dev     = 1
    staging = 2
    prod    = 3
  }
}

# Availability Zones Configuration
variable "azs" {
  description = "List of Availability Zones per workspace"
  type        = map(list(string))
  default = {
    dev     = ["us-east-1a"]
    staging = ["us-east-1a", "us-east-1b"]
    prod    = ["us-east-1a", "us-east-1b", "us-east-1c"]
  }
}