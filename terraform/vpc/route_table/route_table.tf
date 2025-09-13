# Public route table
resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }

  tags = {
    Name = "knowCars-public-rt"
  }
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public_assoc" {
  count          = length(var.public_subnets_ids)
  subnet_id         = var.public_subnets_ids[count.index]
  route_table_id    = aws_route_table.public.id
}

# Private route table
resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  tags = {
    Name = "knowCars-private-rt"
  }
}

resource "aws_route" "private_internet_access" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = var.nat_id
}

# Associate private subnets with private route table
resource "aws_route_table_association" "private_assoc" {
  count          = length(var.private_subnets_ids)
  subnet_id         = var.private_subnets_ids[count.index]
  route_table_id    = aws_route_table.private.id
}

