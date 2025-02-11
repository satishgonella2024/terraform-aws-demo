# Enable ALB only for specific environments
variable "enable_alb" {
  description = "Enable ALB per environment"
  type        = map(bool)
  default = {
    dev     = false
    staging = false
    prod    = true
  }
}

variable "public_subnet_ids" {
  description = "Public subnet IDs per environment"
  type        = map(list(string))
}

variable "alb_security_group" {
  description = "ALB Security Group"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "backend_instance_id" {
  description = "Backend Instance IDs per environment"
  type        = list(string)
  default     = []
}