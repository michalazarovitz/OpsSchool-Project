provider "aws" {
  version = ">= 2.28.1"
  profile = "default"
  region  = "us-west-2"
}

resource "aws_vpc" "midprojvpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "mid_proj_vpc"
  }
}
#public subnets 
resource "aws_subnet" "public-subnets" {
  count = length(var.public_subnets_cidr)
  vpc_id = aws_vpc.midprojvpc.id
  cidr_block = element(var.public_subnets_cidr,count.index)
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = "true"
 

  tags = {
        Name = "public-subnet-${count.index+1}"
        "kubernetes.io/cluster/opsSchool-eks-flask-app" = "shared"
        "kubernetes.io/role/elb" = 1
        Tier = "Public"
    }
}

 #private Subnets
 resource "aws_subnet" "private-subnets" {
  count = length(var.private_subnets_cidr)
  vpc_id = aws_vpc.midprojvpc.id
  cidr_block = element(var.private_subnets_cidr,count.index)
  availability_zone = var.availability_zones[count.index]
 
 

  tags = {
        Name = "private-subnet-${count.index+1}"
        "kubernetes.io/cluster/opsSchool-eks-flask-app" = "shared"
        "kubernetes.io/role/internal-elb" = 1
        Tier = "Private"
        
    }
}

module "instances" {
  source = "../instances"
  #depends_on= [aws_nat_gateway.natgw.*.id]
  vpc_id = aws_vpc.midprojvpc.id
  private_subnets= aws_subnet.private-subnets.*
  public_subnets= aws_subnet.public-subnets.*
  ntgw= aws_nat_gateway.natgw.*.id
  jenkins-sg= aws_security_group.jenkins-sg.id
  mysql-sg= aws_security_group.mysql-sg.id
  consul-sg= aws_security_group.consul-sg.id
  bastion-sg= aws_security_group.bastion-sg.id

}

