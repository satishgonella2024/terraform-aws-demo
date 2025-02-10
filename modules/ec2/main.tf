resource "aws_instance" "bastion" {
  ami             = var.ami
  instance_type   = var.instance_type
  subnet_id       = var.public_subnet_id
  key_name        = var.ssh_key
  security_groups = [var.security_group]
}

resource "aws_instance" "backend" {
  ami             = var.ami
  instance_type   = var.instance_type
  subnet_id       = var.private_subnet_id
  key_name        = var.ssh_key
  security_groups = [var.security_group]
}