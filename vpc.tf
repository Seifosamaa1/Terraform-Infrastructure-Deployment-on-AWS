#-----------vpc--------------------
resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "myvpc"
  }
}

#------------subnet--------------
#public
resource "aws_subnet" "public_subnet" {
  availability_zone = "us-east-1a"
  vpc_id     = "${aws_vpc.myvpc.id}"
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "public-subnet"
  }
}

#private
resource "aws_subnet" "private_subnet" {
  availability_zone = "us-east-1b"
  vpc_id     = "${aws_vpc.myvpc.id}"
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "private-subnet"
  }
}

#------------internet_gateway-------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.myvpc.id}"

  tags = {
    Name = "igw"
  }
}

#------------route_table---------------
#public
resource "aws_route_table" "public_route_table" {
  vpc_id = "${aws_vpc.myvpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "public-route-table"
  }
}

#private
resource "aws_route_table" "private_route_table" {
  vpc_id = "${aws_vpc.myvpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.ngw.id}"
  }

  tags = {
    Name = "private-route-table"
  }
}

#----------route_table_association_to_subnets------------------
#public
resource "aws_route_table_association" "public-and-route" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

#private
resource "aws_route_table_association" "private-and-route" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

#---------------elastic_ip--------------------------
resource "aws_eip" "nat_eip" {
  vpc = true
}

#----------------nat_gateway----------------------
resource "aws_nat_gateway" "ngw" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${aws_subnet.public_subnet.id}"
}

