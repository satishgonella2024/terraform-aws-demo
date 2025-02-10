provider "aws" {
  region = "us-east-1"
}

# VPC Creation
resource "aws_vpc" "learning_vpc_01" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "learning_vpc_01"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "learning_igw_01" {
  vpc_id = aws_vpc.learning_vpc_01.id
  tags = {
    Name = "learning_igw_01"
  }
}

# Public Subnets (For ALB, Bastion, NAT)
resource "aws_subnet" "public_subnets" {
  count                   = 3
  vpc_id                  = aws_vpc.learning_vpc_01.id
  cidr_block              = cidrsubnet("10.0.0.0/20", 3, count.index)
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet_${count.index + 1}"
  }
}

# Private Subnets (For Application Servers)
resource "aws_subnet" "private_app_subnets" {
  count                   = 3
  vpc_id                  = aws_vpc.learning_vpc_01.id
  cidr_block              = cidrsubnet("10.0.16.0/20", 3, count.index)
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "private_app_subnet_${count.index + 1}"
  }
}

# Private Subnets (For Database)
resource "aws_subnet" "private_db_subnets" {
  count                   = 3
  vpc_id                  = aws_vpc.learning_vpc_01.id
  cidr_block              = cidrsubnet("10.0.32.0/20", 3, count.index)
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "private_db_subnet_${count.index + 1}"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

# NAT Gateway for Private Subnets to Access Internet
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = {
    Name = "learning_nat_gateway"
  }
}

# Public Route Table (IGW for Internet Access)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.learning_vpc_01.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.learning_igw_01.id
  }

  tags = {
    Name = "public_rt"
  }
}

# Private Route Table (Using NAT Gateway)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.learning_vpc_01.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "private_rt"
  }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_rt_assoc" {
  count          = 3
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# Associate Private App Subnets with Private Route Table
resource "aws_route_table_association" "private_app_rt_assoc" {
  count          = 3
  subnet_id      = aws_subnet.private_app_subnets[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

# Associate Private DB Subnets with Private Route Table
resource "aws_route_table_association" "private_db_rt_assoc" {
  count          = 3
  subnet_id      = aws_subnet.private_db_subnets[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

# Security Group for RDS (Only allow internal access)
resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.learning_vpc_01.id

  ingress {
    from_port   = 3306 # Change to 5432 for PostgreSQL
    to_port     = 3306 # Change to 5432 for PostgreSQL
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # Allow internal VPC traffic only
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds_security_group"
  }
}

# Subnet Group for RDS (Spans Private DB Subnets)
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = aws_subnet.private_db_subnets[*].id

  tags = {
    Name = "rds_subnet_group"
  }
}

# RDS Database Instance
resource "aws_db_instance" "my_rds" {
  engine                 = "mysql"       # Change to "postgres" for PostgreSQL
  instance_class         = "db.t3.micro" # Free Tier eligible
  allocated_storage      = 20
  storage_type           = "gp2"
  db_name                = "mydatabase"
  username               = "admin"
  password               = "SecurePassword123!" # Store this in AWS Secrets Manager in production
  publicly_accessible    = false
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
  multi_az               = true # Enables high availability across AZs
  skip_final_snapshot    = true

  tags = {
    Name = "my_rds_instance"
  }
}

# Security Group for Public EC2 (Bastion Host)
resource "aws_security_group" "bastion_sg" {
  vpc_id = aws_vpc.learning_vpc_01.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow SSH from anywhere (change to your IP in production)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion_sg"
  }
}

# Upload SSH key to AWS
resource "aws_key_pair" "terraform_key" {
  key_name   = "terraform-key"
  public_key = file("${path.module}/terraform-key.pub")

  tags = {
    Name = "terraform-key"
  }
}

# Public EC2 (Bastion Host)
resource "aws_instance" "bastion" {
  ami                    = "ami-085ad6ae776d8f09c" # Amazon Linux 2 AMI (update based on region)
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnets[0].id
  vpc_security_group_ids = [aws_security_group.bastion_sg.id] # ✅ FIXED

  key_name = aws_key_pair.terraform_key.key_name # Use the generated key
  tags = {
    Name = "bastion_host"
  }
}

# Security Group for Private EC2 (Backend Server)
resource "aws_security_group" "backend_sg" {
  vpc_id = aws_vpc.learning_vpc_01.id

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] # Allow traffic from ALB
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP traffic (optional)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "backend_sg"
  }
}

# Private EC2 (Backend Server)
resource "aws_instance" "backend" {
  ami                    = "ami-085ad6ae776d8f09c" # Amazon Linux 2
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.private_app_subnets[0].id
  vpc_security_group_ids = [aws_security_group.backend_sg.id]  # ✅ FIXED
  key_name               = aws_key_pair.terraform_key.key_name # Use the generated key
  tags = {
    Name = "backend_server"
  }
}

# Create the ALB
resource "aws_lb" "app_alb" {
  name               = "app-load-balancer"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public_subnets[*].id

  tags = {
    Name = "app_alb"
  }
}

# Target Group for Backend Instances
resource "aws_lb_target_group" "app_target_group" {
  name        = "app-target-group"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.learning_vpc_01.id
  target_type = "instance"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "app_target_group"
  }
}

# Attach Backend Instances to Target Group
resource "aws_lb_target_group_attachment" "tg_attachment" {
  count            = length(aws_instance.backend[*].id)
  target_group_arn = aws_lb_target_group.app_target_group.arn
  target_id        = aws_instance.backend.id
  port             = 80
}

# Listener to forward HTTP traffic to Target Group
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}
