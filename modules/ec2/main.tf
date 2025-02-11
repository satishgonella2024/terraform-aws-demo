resource "aws_instance" "bastion" {
  ami             = var.ami
  instance_type   = lookup(var.instance_type, terraform.workspace, "t2.micro")
  subnet_id       = lookup(var.public_subnet_ids, terraform.workspace, null)
  key_name        = var.ssh_key
  security_groups = [var.security_group]

  tags = {
    Name        = "bastion-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

resource "aws_instance" "backend" {
  count = terraform.workspace == "prod" ? 3 : 1  # ✅ 3 instances in prod, 1 in others

  ami           = var.ami
  instance_type = lookup(var.instance_type, terraform.workspace, "t2.micro")  # ✅ Dynamically select instance type
  subnet_id     = element(lookup(var.private_subnet_ids, terraform.workspace, []), count.index)
  key_name      = var.ssh_key

  tags = {
    Name        = "backend-${terraform.workspace}-${count.index}"
    Environment = terraform.workspace
  }
}