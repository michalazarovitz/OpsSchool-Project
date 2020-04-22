resource "aws_instance" "promcol" {
  ami           = var.ami
  instance_type = "t2.micro"
  key_name      = var.key_name
  subnet_id = element(var.public_subnets.*.id, 1)
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  vpc_security_group_ids = [var.consul-sg]
  user_data = data.template_cloudinit_config.consul_client.2.rendered
 
  tags = {
    Name = "Prometheus"
  }

  
}


