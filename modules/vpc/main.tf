resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr[terraform.workspace]
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.vpc_name}-${terraform.workspace}"
    Environment = terraform.workspace
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = { Name = "Internet Gateway" }
}

# Public Subnets
resource "aws_subnet" "public" {
  count = lookup(var.subnet_count, terraform.workspace, 1)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr[terraform.workspace], 4, count.index)
  availability_zone       = element(var.azs[terraform.workspace], count.index)
  map_public_ip_on_launch = true

  tags = {
    Name        = "public_subnet_${terraform.workspace}_${count.index + 1}"
    Environment = terraform.workspace
  }
}

# Private App Subnets
resource "aws_subnet" "private" {
  count = lookup(var.subnet_count, terraform.workspace, 1)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr[terraform.workspace], 4, count.index + 3)
  availability_zone       = element(var.azs[terraform.workspace], count.index)

  tags = {
    Name        = "private_app_subnet_${terraform.workspace}_${count.index + 1}"
    Environment = terraform.workspace
  }
}

# Private DB Subnets
resource "aws_subnet" "private_db" {
  count = lookup(var.subnet_count, terraform.workspace, 1)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr[terraform.workspace], 4, count.index + 6)
  availability_zone       = element(var.azs[terraform.workspace], count.index)

  tags = {
    Name        = "private_db_subnet_${terraform.workspace}_${count.index + 1}"
    Environment = terraform.workspace
  }
}

# Elastic IP for NAT Gateway (Only in prod)
resource "aws_eip" "nat_eip" {
  count  = terraform.workspace == "prod" ? 1 : 0
  domain = "vpc"
}

# NAT Gateway (Only in prod)
resource "aws_nat_gateway" "nat_gateway" {
  count         = terraform.workspace == "prod" ? 1 : 0
  allocation_id = aws_eip.nat_eip[0].id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "nat_gateway-${terraform.workspace}"
  }
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "public_route_table" }
}

# Private Route Table (Only in prod)
resource "aws_route_table" "private_rt" {
  count  = terraform.workspace == "prod" ? 1 : 0
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway[0].id
  }

  tags = { Name = "private_route_table-${terraform.workspace}" }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_rt_assoc" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

# Associate Private App Subnets with Private Route Table (Only in prod)
resource "aws_route_table_association" "private_rt_assoc" {
  count          = terraform.workspace == "prod" ? length(aws_subnet.private) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private_rt[0].id
}