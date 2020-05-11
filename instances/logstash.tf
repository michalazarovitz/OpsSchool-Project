resource "aws_instance" "logstash" {
  ami           = var.ami
  instance_type = "t2.small"
  key_name      = var.key_name
  subnet_id = element(var.private_subnets.*.id, 0)
  vpc_security_group_ids = [var.elk-sg, var.consul-agents-sg, var.node-exporter-sg]
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  user_data = data.template_cloudinit_config.consul_client.0.rendered


 
  tags = {
    Name = "logstash"
  }



}

output "logstash" {
  value = ["${aws_instance.logstash.public_ip}"]
}