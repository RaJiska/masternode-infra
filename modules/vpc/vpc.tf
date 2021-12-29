resource "aws_vpc" "vpc" {
  cidr_block = var.cidr

  tags = {
    Name = var.name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = var.name
  }
}