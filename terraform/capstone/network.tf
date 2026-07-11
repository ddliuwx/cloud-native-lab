resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "${var.project_name}-nat-eip"
  }

}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = module.vpc.public_subnet_id

  tags = {
    Name = "${var.project_name}-nat-gateway"
  }

  depends_on = [module.vpc]

}

resource "aws_route_table" "private" {
  vpc_id = module.vpc.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

resource "aws_route_table_association" "private" {
  subnet_id      = module.vpc.private_subnet_id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = module.vpc.private_subnet_b_id
  route_table_id = aws_route_table.private.id

}