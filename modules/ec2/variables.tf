variable "ami" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-0c104f6f4a5d9d1d5"  # ✅ Use the correct AMI ID
}
variable "instance_type" {}
variable "public_subnet_id" {}
variable "private_subnet_id" {}
variable "ssh_key" {}
variable "security_group" {}