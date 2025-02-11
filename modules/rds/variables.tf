# VPC ID
variable "vpc_id" {}

# Database Engine
variable "db_engine" {
  description = "Database engine (mysql, postgres, etc.)"
  type        = string
  default     = "mysql"
}

# Instance type per environment
variable "db_instance_type" {
  description = "DB instance type per environment"
  type        = map(string)
  default = {
    dev     = "db.t3.micro"
    staging = "db.t3.small"
    prod    = "db.t3.medium"
  }
}

# Allocated storage per environment
variable "db_allocated_storage" {
  description = "Storage per environment"
  type        = map(number)
  default = {
    dev     = 10
    staging = 20
    prod    = 50
  }
}

# Database Name
variable "db_name" {
  description = "Database name"
  type        = string
  default     = "mydatabase"
}

# Username
variable "db_username" {
  description = "Database username"
  type        = string
  default     = "admin"
}

# Password (⚠️ Consider AWS Secrets Manager)
variable "db_password" {
  description = "Database password"
  type        = string
  default     = "SecurePassword123!" # ⚠️ Replace with AWS Secrets Manager
}

# Database Port
variable "db_port" {
  description = "Database Port"
  type        = number
  default     = 3306
}

# Allowed CIDR Blocks
variable "allowed_cidrs" {
  description = "List of allowed CIDRs for database access"
  type        = list(string)
  default     = ["10.0.0.0/16"]  # ✅ Restrict to VPC by default
}

# Private Subnet IDs per environment
variable "private_db_subnet_ids" {
  description = "Private Subnet IDs for RDS per environment"
  type        = map(list(string))
}