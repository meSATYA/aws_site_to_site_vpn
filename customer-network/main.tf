
# Internet VPC
resource "aws_vpc" "customer-vpc" {
  cidr_block           = var.VPC_CIDR
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "customer-vpc"
  }
}


# Subnets
resource "aws_subnet" "customer-vpc-public-subnet-1" {
  vpc_id                  = aws_vpc.customer-vpc.id
  cidr_block              = "172.31.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "customer-vpc-public-subnet-1"
  }
}

resource "aws_subnet" "customer-vpc-private-subnet-1" {
  vpc_id                  = aws_vpc.customer-vpc.id
  cidr_block              = "172.31.2.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "us-east-1a"

  tags = {
    Name = "customer-vpc-private-subnet-1"
  }
}


# Internet GW
resource "aws_internet_gateway" "customer-vpc-igw" {
  vpc_id = aws_vpc.customer-vpc.id

  tags = {
    Name = "customer-vpc"
  }
}

# route tables
resource "aws_route_table" "customer-vpc-public-route" {
  vpc_id = aws_vpc.customer-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.customer-vpc-igw.id
  }

  tags = {
    Name = "customer-vpc-public-route"
  }
}

# route associations public
resource "aws_route_table_association" "customer-vpc-public-1-a-route-association" {
  subnet_id      = aws_subnet.customer-vpc-public-subnet-1.id
  route_table_id = aws_route_table.customer-vpc-public-route.id
}

resource "aws_security_group" "allow-ssh-icmp" {
  vpc_id      = aws_vpc.customer-vpc.id
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
    Name = "allow-ssh-icmp"
  }
}

resource "aws_key_pair" "mykeypair" {
  key_name   = "mykey"
  public_key = file("${var.PATH_TO_PUBLIC_KEY}")
}

resource "aws_instance" "customer_instance" {
  ami            = lookup(var.AMIS, var.AWS_REGION)
  instance_type  = "t2.micro"

  # the VPC subnet
  subnet_id = aws_subnet.customer-vpc-public-subnet-1.id

  # the security group
  vpc_security_group_ids = ["${aws_security_group.allow-ssh-icmp.id}"]

  # the public SSH key
  key_name = aws_key_pair.mykeypair.key_name
  
  tags = {
   Name = "customer-instance"
  }
}
resource "aws_instance" "openswan_instance" {
  ami            = lookup(var.AMIS, var.AWS_REGION)
  instance_type  = "t2.micro"

  # the VPC subnet
  subnet_id = aws_subnet.customer-vpc-public-subnet-1.id

  # the security group
  vpc_security_group_ids = ["${aws_security_group.allow-ssh-icmp.id}"]

  # the public SSH key
  key_name = aws_key_pair.mykeypair.key_name

  source_dest_check = false

  tags = {
    Name = "openswan-instance"
  }

}
