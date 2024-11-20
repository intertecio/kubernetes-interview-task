data "aws_caller_identity" "current" {}

/* VPC */
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = var.tags
}

/* IGW */
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id

  tags = var.tags
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnets.*.id, 0)
  depends_on    = [aws_internet_gateway.ig]

  tags = var.tags
}

resource "aws_eip" "nat_eip" {
  depends_on = [aws_internet_gateway.ig]
}

/* Subnets */
resource "aws_subnet" "public_subnets" {
  count = length(var.vpc.public_subnets_cidr)

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.vpc.public_subnets_cidr[count.index]
  availability_zone       = element(var.vpc.availability_zones, (count.index % length(var.vpc.availability_zones)))
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    "kubernetes.io/role/elb" = "1"
  })
}

resource "aws_subnet" "private_subnets" {
  count = length(var.vpc.private_subnets_cidr)

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.vpc.private_subnets_cidr[count.index]
  availability_zone       = element(var.vpc.availability_zones, (count.index % length(var.vpc.availability_zones)))
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    "kubernetes.io/role/internal-elb" = "1"
  })
}

/* Routing tables */
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  tags = var.tags
}

/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  tags = var.tags
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

/* Route tables associations */
resource "aws_route_table_association" "public" {
  count = length(var.vpc.public_subnets_cidr)

  subnet_id      = element(aws_subnet.public_subnets.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(var.vpc.private_subnets_cidr)

  subnet_id      = element(aws_subnet.private_subnets.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

