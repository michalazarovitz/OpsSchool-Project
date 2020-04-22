data "template_file" "logstash" {
  template = file("${path.module}/templates/logstash.sh.tpl")
  vars = {
      elasticsearch_host = "${aws_instance.elasticsearch.private_ip}" 
    }
}

resource "aws_instance" "logstash" {
  ami           = var.ami
  instance_type = "t2.small"
  key_name      = var.key_name
  subnet_id = element(var.private_subnets.*.id, 0)
  vpc_security_group_ids = [var.consul-sg]
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  user_data = data.template_file.logstash.rendered

 
  tags = {
    Name = "logstash"
  }



}

output "logstash" {
  value = ["${aws_instance.logstash.public_ip}"]
}