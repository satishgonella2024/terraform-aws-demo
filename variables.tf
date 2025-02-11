variable "vpc_cidr" {
  description = "VPC CIDR block per environment"
  type        = map(string)
  default = {
    dev     = "10.0.0.0/24"
    staging = "10.0.0.0/22"
    prod    = "10.0.0.0/16"
  }
}

variable "public_subnets" {
  description = "Public subnets per environment"
  type        = map(list(string))
  default = {
    dev     = ["10.0.1.0/24"]
    staging = ["10.0.1.0/24", "10.0.2.0/24"]
    prod    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  }
}

variable "private_subnets" {
  description = "Private subnets per environment"
  type        = map(list(string))
  default = {
    dev     = ["10.0.10.0/24"]
    staging = ["10.0.10.0/24", "10.0.20.0/24"]
    prod    = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
  }
}

variable "azs" {
  description = "Availability zones per environment"
  type        = map(list(string))
  default = {
    dev     = ["us-east-1a"]
    staging = ["us-east-1a", "us-east-1b"]
    prod    = ["us-east-1a", "us-east-1b", "us-east-1c"]
  }
}

variable "instance_type" {
  description = "EC2 instance type per environment"
  type        = map(string)
  default = {
    dev     = "t2.micro"
    staging = "t3.small"
    prod    = "t3.large"
  }
}

variable "enable_alb" {
  description = "Enable ALB only for production"
  type        = map(bool)
  default = {
    dev     = false
    staging = false
    prod    = true
  }
}