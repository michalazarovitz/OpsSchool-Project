variable "region" {
  default = "us-west-2"
}

variable "availability_zones" {
  default = ["us-west-2a", "us-west-2b"]
  type = "list"
}

variable "vpc_cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
  type = "list"
}

variable "private_subnets_cidr" {
  default = ["10.0.3.0/24", "10.0.4.0/24"]
  type = "list"
}






