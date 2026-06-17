# Fetch available AWS Availability Zones dynamically
data "aws_availability_zones" "available" {
  state = "available"
}

# 1. The Core Virtual Private Cloud
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

# 2. Public Subnets (For Load Balancers & Internet Gateways)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "${var.environment}-public-${count.index + 1}"
    "kubernetes.io/role/elb"                    = "1" # Crucial tag so AWS EKS can find public load balancers
    Environment                                 = var.environment
  }
}

# 3. Private Subnets (Where your EKS app nodes will live securely)
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name                                        = "${var.environment}-private-${count.index + 1}"
    "kubernetes.io/role/internal-elb"           = "1" # Crucial tag for internal cluster routing
    Environment                                 = var.environment
  }
}

# 4. Internet Gateway (Allows traffic out from public subnets)
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.environment}-igw"
  }
}

# 5. Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.gw]
}

# 6. NAT Gateway (Allows secure private apps to fetch updates from internet safely)
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # Place NAT inside our first public subnet

  tags = {
    Name = "${var.environment}-nat-gw"
  }
}

# 7. Route Tables & Associations (Telling traffic where to flow)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = { Name = "${var.environment}-public-rt" }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = { Name = "${var.environment}-private-rt" }
}

resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}