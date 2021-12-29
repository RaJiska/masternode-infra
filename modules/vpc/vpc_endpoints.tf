resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.${var.region}.s3"
}

resource "aws_vpc_endpoint_route_table_association" "public" {
  route_table_id  = aws_route_table.public.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_vpc_endpoint_route_table_association" "private" {
  route_table_id  = aws_route_table.private.id
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}