# Create NAT Gateway in the first public subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = var.eip_id
  subnet_id     = var.public_subnet_ids[0]
  tags = {
    Name = "knowCars-nat-gateway"
  }
}
