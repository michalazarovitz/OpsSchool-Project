#Internet gateway
resource "aws_internet_gateway" "midproj-igw" {
    vpc_id = aws_vpc.midprojvpc.id
    
    }
#route Tables
resource "aws_route_table" "public-rt" {
    vpc_id = "${aws_vpc.midprojvpc.id}"
    route {
        cidr_block = "0.0.0.0/0" 
        gateway_id = "${aws_internet_gateway.midproj-igw.id}"
    }
    tags = {
        Name = "midproj-public-rt"
    }    
}

   resource "aws_route_table" "private-rt" {
    count  = "${length(var.private_subnets_cidr)}"
    vpc_id = "${aws_vpc.midprojvpc.id}"
    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = element(aws_nat_gateway.natgw.*.id, count.index)
    }
    tags = {
        Name = "private-rt-${count.index+1}"
    }
  }

#assiosate public subnets with rotute table
resource "aws_route_table_association" "public-association" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public-subnets.*.id, count.index)
  route_table_id = aws_route_table.public-rt.id
}


#assiosate private subnets with rotute table
resource "aws_route_table_association" "private-assoc-1" {
 count          = length(var.private_subnets_cidr)
 subnet_id      = element(aws_subnet.private-subnets.*.id, count.index)
 route_table_id = element(aws_route_table.private-rt.*.id, count.index)
}


 #NAT
resource "aws_eip" "nat" {
  count = length(var.public_subnets_cidr)
  vpc        = true
}


resource "aws_nat_gateway" "natgw" {
  count = length(var.public_subnets_cidr)
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id     = element(aws_subnet.public-subnets.*.id, count.index)
  tags = {
    Name = "midproj-NAT-${count.index+1}"
  }
}


