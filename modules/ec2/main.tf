resource "aws_instance" "bastion" {
  ami             = var.ami
  instance_type   = var.instance_type
  subnet_id       = var.public_subnet_id
  key_name        = var.ssh_key
  security_groups = [var.security_group]
}

resource "aws_instance" "backend" {
  count = terraform.workspace == "prod" ? 3 : 1 # ✅ 3 instances in prod, 1 in others

  ami           = var.ami
  instance_type = var.instance_type[terraform.workspace] # ✅ Select based on workspace
  subnet_id     = element(module.vpc.private_subnet_ids, count.index)
  key_name      = aws_key_pair.ssh_key.key_name

  tags = {
    Name        = "backend-${terraform.workspace}-${count.index}"
    Environment = terraform.workspace
  }
}