resource "aws_instance" "db" {
  ami = var.ami
  instance_type = "t2.micro"
  key_name = "Mid-proj"
  subnet_id= element(var.private_subnets.*.id,1)
  associate_public_ip_address= false
  vpc_security_group_ids = [var.mysql-sg, var.consul-agents-sg]
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  user_data = data.template_cloudinit_config.consul_client.3.rendered

   
  tags = {
    Name = "Mysql server"
  }
  
}