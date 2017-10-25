# -------------------Front subnets -------------------------------------------------------------------------------------------------
resource "aws_subnet" "front-a" {
  vpc_id                  = "${aws_vpc.vpc-mld.id}"
  cidr_block              = "${var.my_cidr_block}.0.0/27"
  availability_zone       = "${var.region}a"
  map_public_ip_on_launch = true

  tags {
    Name     = "front_a"
    Customer = "Renault"
  }
}

resource "aws_subnet" "front-b" {
  vpc_id                  = "${aws_vpc.vpc-mld.id}"
  cidr_block              = "${var.my_cidr_block}.0.32/27"
  availability_zone       = "${var.region}b"
  map_public_ip_on_launch = true

  tags {
    Name     = "front_b"
    Customer = "Renault"
  }
}

# -------------------------- Routing to internet GW ----------------------------------------------------------
resource "aws_internet_gateway" "gw-to-internet-mld" {
  vpc_id = "${aws_vpc.vpc-mld.id}"
}

resource "aws_route_table" "route-to-gw" {
  vpc_id = "${aws_vpc.vpc-mld.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw-to-internet-mld.id}"
  }

  tags {
    Name = "Route-to-igw"
  }
}

resource "aws_route_table_association" "front-a" {
  subnet_id      = "${aws_subnet.front-a.id}"
  route_table_id = "${aws_route_table.route-to-gw.id}"
}

resource "aws_route_table_association" "front-b" {
  subnet_id      = "${aws_subnet.front-b.id}"
  route_table_id = "${aws_route_table.route-to-gw.id}"
}
