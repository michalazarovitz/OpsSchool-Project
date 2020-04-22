resource "aws_instance" "elasticsearch" {
  ami           = var.ami
  instance_type = "t2.medium"
  key_name      = var.key_name
  subnet_id = element(var.private_subnets.*.id, 1)
  vpc_security_group_ids = [var.consul-sg]
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  user_data = "${file("${path.module}/templates/elasticsearch.sh")}"


 tags = {
    Name = "elasticsearch"
  }


}

output "elasticsearch" {
  value = ["${aws_instance.elasticsearch.private_ip}"]
}