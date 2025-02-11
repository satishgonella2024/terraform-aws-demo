resource "aws_security_group" "rds_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds_security_group"
    Environment = terraform.workspace
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group-${terraform.workspace}"
  subnet_ids = lookup(var.private_db_subnet_ids, terraform.workspace, []) # ✅ Fix workspace reference

  tags = {
    Name = "rds_subnet_group-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

resource "aws_db_instance" "rds_instance" {
  engine                 = var.db_engine
  instance_class         = lookup(var.db_instance_type, terraform.workspace, "db.t3.micro") # ✅ Adjust per workspace
  allocated_storage      = lookup(var.db_allocated_storage, terraform.workspace, 20) # ✅ Set storage dynamically
  storage_type           = "gp2"
  db_name                = var.db_name
  username               = var.db_username
  password               = var.db_password  # ⚠️ Ideally, store in **AWS Secrets Manager**
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  multi_az               = terraform.workspace == "prod" ? true : false  # ✅ Multi-AZ **only in prod**
  skip_final_snapshot    = true

  tags = {
    Name        = "rds_instance-${terraform.workspace}"
    Environment = terraform.workspace
  }
}