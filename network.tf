# =========================
# Local Variables - Subnets Definition
# =========================
locals {
  public_subnets = {
    "public-a" = { cidr = "10.0.1.0/24", az_index = 0 }
    "public-b" = { cidr = "10.0.2.0/24", az_index = 1 }
  }
}

# =========================
# Data Source - Availability Zones
# =========================
data "aws_availability_zones" "available" {
  state = "available"
}

# =========================
# VPC - Core Network
# =========================
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# =========================
# Internet Gateway - Public Internet Access
# =========================
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# =========================
# Public Subnets - Multi AZ (FOR EACH)
# =========================
resource "aws_subnet" "public" {
  for_each = local.public_subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = data.aws_availability_zones.available.names[each.value.az_index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${each.key}"
  }
}

# =========================
# Route Table - Public Routing
# =========================
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# =========================
# Route Table Association - Subnets to Internet
# =========================
resource "aws_route_table_association" "public" {
  for_each = aws_subnet.public

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}