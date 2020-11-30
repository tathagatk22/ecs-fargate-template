provider "aws" {
  version = "~> 3.0"
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpc_ecs"
  }
}

# Create a Private Subnet
resource "aws_subnet" "subnet_private" {
  depends_on = [
    aws_vpc.vpc
  ]
  vpc_id = aws_vpc.vpc.id
  availability_zone = "us-east-1a"
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "subnet_private"
  }
  map_public_ip_on_launch = true
}

# Create a Private Subnet
resource "aws_subnet" "subnet_private_2" {
  depends_on = [
    aws_vpc.vpc
  ]
  vpc_id = aws_vpc.vpc.id
  availability_zone = "us-east-1b"
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "subnet_private_2"
  }
  map_public_ip_on_launch = true
}
# Create a Public Subnet
resource "aws_subnet" "subnet_public" {
  depends_on = [
    aws_vpc.vpc
  ]
  vpc_id = aws_vpc.vpc.id
  availability_zone = "us-east-1a"
  cidr_block = "10.0.3.0/24"
  tags = {
    Name = "subnet_public"
  }
}

# Create a Internet Gateway
resource "aws_internet_gateway" "internet_gateway" {
  depends_on = [
    aws_vpc.vpc,
    aws_subnet.subnet_public,
    aws_subnet.subnet_private
  ]
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "internet_gateway"
  }
}

# Create a Public Route Table
resource "aws_route_table" "public_route_table" {
  depends_on = [
    aws_vpc.vpc,
    aws_internet_gateway.internet_gateway
  ]
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name = "public_route_table"
  }
}

# Public Route Table Association
resource "aws_route_table_association" "public_rt_association" {

  depends_on = [
    aws_vpc.vpc,
    aws_subnet.subnet_public,
    aws_subnet.subnet_private,
    aws_route_table.public_route_table
  ]
  subnet_id = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.public_route_table.id
}

# Security Group 
resource "aws_security_group" "security-group" {

  depends_on = [
    aws_vpc.vpc,
    aws_subnet.subnet_public,
    aws_subnet.subnet_private
  ]

  description = "HTTP, PING, SSH"

  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 0
    to_port = 0
    protocol = "ICMP"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }
  tags = {
    Name = "sg-ecs"
  }
}

# Creating a EIP for NAT gateway
resource "aws_eip" "nat_eip" {
  vpc = true
  tags = {
    Name = "nat_eip"
  }
}

# Creating a NAT gateway
resource "aws_nat_gateway" "nat_gw" {
  depends_on = [
    aws_subnet.subnet_public,
    aws_eip.nat_eip,
  ]
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.subnet_public.id

  tags = {
    Name = "nat_gateway"
  }
}

# Create a Private Route Table
resource "aws_route_table" "NAT_route_table" {
  depends_on = [
    aws_vpc.vpc,
    aws_nat_gateway.nat_gw,
  ]

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "NAT_route_table"
  }
}

# Private Route Table Association
resource "aws_route_table_association" "private_rt_association" {
  depends_on = [
    aws_subnet.subnet_private,
    aws_route_table.NAT_route_table,
  ]
  subnet_id = aws_subnet.subnet_private.id
  route_table_id = aws_route_table.NAT_route_table.id
}

# Private Route Table Association
resource "aws_route_table_association" "private_2_rt_association" {
  depends_on = [
    aws_subnet.subnet_private_2,
    aws_route_table.NAT_route_table,
  ]
  subnet_id = aws_subnet.subnet_private_2.id
  route_table_id = aws_route_table.NAT_route_table.id
}