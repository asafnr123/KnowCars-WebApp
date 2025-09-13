# Public NACL
resource "aws_network_acl" "public" {
  vpc_id = var.vpc_id

  tags = {
    Name = "knowCars-public-nacl"
  }
}

# Allow inbound HTTPS
resource "aws_network_acl_rule" "public_inbound_https" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}


# Allow all outbound traffic
resource "aws_network_acl_rule" "public_outbound" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 110
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}


# Private NACL
resource "aws_network_acl" "private" {
  vpc_id = var.vpc_id

  tags = {
    Name = "knowCars-private-nacl"
  }
}

# Allow all inbound traffic from within the VPC
resource "aws_network_acl_rule" "private_inbound_local" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
}

# Allow all outbound traffic within the VPC
resource "aws_network_acl_rule" "private_outbound_local" {
  network_acl_id = aws_network_acl.private.id
  rule_number    = 110
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = var.vpc_cidr
}


# Associations
resource "aws_network_acl_association" "public_assoc" {
  count       = length(var.public_subnet_ids)
  subnet_id      = var.public_subnets_ids[count.index]
  network_acl_id = aws_network_acl.public.id
}

resource "aws_network_acl_association" "private_assoc" {
  count          = length(var.private_subnet_ids)
  subnet_id         = var.private_subnets_ids[count.index]
  network_acl_id = aws_network_acl.private.id
}

