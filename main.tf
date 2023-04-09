data "aws_ami" "al2023_arm" {
  most_recent = true

  filter {
    name   = "name"
    values = ["al2023-ami-minimal-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }
}

resource "aws_spot_instance_request" "testing-al2023-arm" {
  ami                         = data.aws_ami.al2023_arm.id
  instance_type               = "t4g.micro"
  spot_price                  = "0.006"
  key_name                    = var.ec2_key_name
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.all_inbound_ip_sg.id, aws_security_group.all_outbound_ip_sg.id, aws_security_group.ssh_sg.id]
  associate_public_ip_address = true

  user_data = file("install-docker-nginx.sh")

  tags = {
    Name = "testing-al2023-arm"
  }
}

/* VPC */
resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "VPC test"
  }
}

/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "IGW test"
  }
}

/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}

/* NAT */
resource "aws_nat_gateway" "nat_test" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name = "nat_test"
  }
}

/* Public Subnet */
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "public_subnet_test"
  }
}

/* Private Subnet */
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = false
  tags = {
    Name = "private_subnet_test"
  }
}

/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "private-route-table"
  }
}

/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "public-route-table"
  }
}

/* Public Route */
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

/* Private Route */
resource "aws_route" "public_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_test.id
}

/* Route table associations */
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private.id
}
