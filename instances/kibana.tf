resource "aws_instance" "kibana" {
  depends_on= [aws_instance.elasticsearch]
  ami           = var.ami
  instance_type = "t2.micro"
  key_name      = var.key_name
  subnet_id = element(var.private_subnets.*.id, 1)
  vpc_security_group_ids = [var.elk-sg, var.consul-agents-sg]
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  user_data = data.template_cloudinit_config.consul_client.2.rendered


 
  tags = {
    Name = "kibana"
  }


}