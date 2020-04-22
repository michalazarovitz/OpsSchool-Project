resource "aws_instance" "bastion" {
  ami           = var.ami
  instance_type = "t2.micro"
  key_name      = var.key_name
  subnet_id = element(var.public_subnets.*.id, 1)
  vpc_security_group_ids = [var.bastion-sg]
   
  tags = {
    Name = "bastion"
  }

  
}


