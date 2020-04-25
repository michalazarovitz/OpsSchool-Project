variable "vpc_id" {
  type    = string
  default = "midprojvpcid"
}

data "external" "myipaddr" {
  program = ["bash", "-c", "curl -s 'https://api.ipify.org?format=json'"]
}

variable "additional_ip_addresses_for_eks_access" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

data "aws_subnet_ids" "eks_subnets" {
  vpc_id = var.vpc_id
}

data "aws_subnet_ids" "eks_private_subnets" {
  vpc_id = var.vpc_id
  tags = {
    Tier = "Private"
  }
}

data "aws_vpc" "eks_vpc" {
  id = "${var.vpc_id}"
}

terraform {
  required_version = ">= 0.12.0"
}

provider "aws" {
  version = ">= 2.28.1"
  profile = "default"
  region  = "us-west-2"
}

provider "random" {
  version = "~> 2.1"
}

provider "local" {
  version = "~> 1.2"
}

provider "null" {
  version = "~> 2.1"
}

provider "template" {
  version = "~> 2.1"
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
 
}

data "aws_availability_zones" "available" {
}

locals {
  cluster_name = "opsSchool-eks-flask-app"
}


# CIDR will be "My IP" \ all Ips from which you need to access the worker nodes
resource "aws_security_group" "worker_group_mgmt" {
  name_prefix = "worker_group_mgmt"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = var.additional_ip_addresses_for_eks_access

  }
 
  egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.3.0/24", "10.0.4.0/24"]
  }
}


resource "aws_security_group" "all_worker_mgmt" {
  name_prefix = "all_worker_management"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

    egress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.3.0/24", "10.0.4.0/24"]
  }
}

module "eks" {
  source       = "terraform-aws-modules/eks/aws"
  cluster_name = local.cluster_name
  subnets      = data.aws_subnet_ids.eks_subnets.ids

  tags = {
    Environment = "test"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }

  vpc_id = var.vpc_id

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.medium"
      subnets      = data.aws_subnet_ids.eks_private_subnets.ids
      asg_desired_capacity          = 2
      additional_security_group_ids = [aws_security_group.worker_group_mgmt.id]
      key_name = "Mid-proj"
    }

  ]

  worker_additional_security_group_ids = [aws_security_group.all_worker_mgmt.id]

}



