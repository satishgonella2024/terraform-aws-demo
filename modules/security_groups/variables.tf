variable "vpc_id" {
  description = "VPC ID for security groups"
  type        = string
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs for internal access"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "allowed_ssh_cidr" {
  description = "Allowed CIDR block for SSH access"
  type        = string
  default     = "YOUR-IP/32"  # ✅ Change this to your actual IP!
}