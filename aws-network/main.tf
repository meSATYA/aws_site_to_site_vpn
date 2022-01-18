
# Internet VPC
resource "aws_vpc" "aws-vpc" {
  cidr_block           = var.VPC_CIDR
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "aws-vpc"
  }
}


# Subnets

resource "aws_subnet" "aws-vpc-private-subnet-1" {
  vpc_id                  = aws_vpc.aws-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "${var.AWS_REGION}a"

  tags = {
    Name = "aws-vpc-private-subnet-1"
  }
}

resource "aws_route_table" "custom-aws-route" {
 vpc_id = aws_vpc.aws-vpc.id
 tags = {
 Name = "aws-network-route-table"
 }
}

resource "aws_security_group" "allow-ssh-icmp-aws" {
  vpc_id      = aws_vpc.aws-vpc.id
  name        = "allow-ssh-icmp"
  description = "security group that allows ssh and all egress traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "allow-ssh-icmp-aws"
  }
}

resource "aws_key_pair" "mykeypairaws" {
  key_name   = "mykeyaws"
  public_key = file("${var.PATH_TO_PUBLIC_KEY}")
}

resource "aws_vpn_gateway" "vpn-vpg" {
  vpc_id = aws_vpc.aws-vpc.id

  tags = {
    Name = "vpn-vpg"
  }
}

resource "aws_vpn_gateway_route_propagation" "main" {
  vpn_gateway_id = aws_vpn_gateway.vpn-vpg.id
  route_table_id = aws_route_table.custom-aws-route.id
}

resource "aws_customer_gateway" "customer-gateway" {
  bgp_asn = 65000
  ip_address = "18.208.224.140"
  type       = "ipsec.1"

  tags = {
    Name = "main-customer-gateway"
  }
}


resource "aws_vpn_connection" "aws-vpn" {
  vpn_gateway_id      = aws_vpn_gateway.vpn-vpg.id
  customer_gateway_id = aws_customer_gateway.customer-gateway.id
  type                = "ipsec.1"
  static_routes_only  = true
  tags = {
    Name = "AWS_VPN"
  }
}

resource "aws_instance" "aws_private_instance" {
  ami            = lookup(var.AMIS, var.AWS_REGION)
  instance_type  = "t2.micro"

  # the VPC subnet
  subnet_id = aws_subnet.aws-vpc-private-subnet-1.id

  # the security group
  vpc_security_group_ids = ["${aws_security_group.allow-ssh-icmp-aws.id}"]

  # the public SSH key
  key_name = aws_key_pair.mykeypairaws.key_name
  
  tags = {
   Name = "aws-private-instance"
  }
}


