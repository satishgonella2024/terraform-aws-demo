resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = { Name = "Internet Gateway" }
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = 3  # ✅ Ensure this is set to 3
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index)
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = { Name = "public_subnet_${count.index + 1}" }
}

# Private Subnets (Application Layer)
resource "aws_subnet" "private" {
  count                   = 3  # ✅ Ensure this is set to 3
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index + 3)
  availability_zone       = var.azs[count.index]

  tags = { Name = "private_app_subnet_${count.index + 1}" }
}

# Private Subnets (Database Layer)
resource "aws_subnet" "private_db" {
  count                   = 3  # ✅ Ensure this is set to 3
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index + 6)
  availability_zone       = var.azs[count.index]

  tags = { Name = "private_db_subnet_${count.index + 1}" }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

# NAT Gateway for Private Subnets
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public[0].id  # NAT Gateway must be in a public subnet

  tags = { Name = "nat_gateway" }
}

# Public Route Table (For Internet Gateway)
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "public_route_table" }
}

# Private Route Table (For NAT Gateway)
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = { Name = "private_route_table" }
}

# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_rt_assoc" {
  count          = length(aws_subnet.public)  # ✅ Ensure correct count
  subnet_id      = aws_subnet.public[count.index].id  # ✅ Correct reference
  route_table_id = aws_route_table.public_rt.id
}

# Associate Private App Subnets with Private Route Table
resource "aws_route_table_association" "private_app_rt_assoc" {
  count          = length(aws_subnet.private)  # ✅ Ensure correct count
  subnet_id      = aws_subnet.private[count.index].id  # ✅ Correct reference
  route_table_id = aws_route_table.private_rt.id
}

# Associate Private DB Subnets with Private Route Table
resource "aws_route_table_association" "private_db_rt_assoc" {
  count          = length(aws_subnet.private_db)  # ✅ Ensure correct count
  subnet_id      = aws_subnet.private_db[count.index].id  # ✅ Correct reference
  route_table_id = aws_route_table.private_rt.id
}





