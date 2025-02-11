variable "azs" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "instance_type" {
  description = "EC2 instance type based on environment"
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

variable "subnet_count" {
  description = "Number of subnets per environment"
  type        = map(number)
  default = {
    dev     = 1
    staging = 1
    prod    = 3
  }
}