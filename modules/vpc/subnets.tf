resource "aws_subnet" "public" {
  count = length(var.azs)

  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnets_cidr[count.index].public
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-public-${count.index + 1}"
  }
}

resource "aws_subnet" "private" {
  count = length(var.azs)

  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnets_cidr[count.index].private
  availability_zone = var.azs[count.index]

  tags = {
    Name = "${var.name}-private-${count.index + 1}"
  }
}