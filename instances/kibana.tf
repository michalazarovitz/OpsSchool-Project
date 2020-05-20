resource "aws_instance" "kibana" {
  depend_on= [aws_instance.jenkins_master]
  ami           = var.ami
  instance_type = "t2.micro"
  key_name      = var.key_name
  subnet_id = element(var.private_subnets.*.id, 1)
  vpc_security_group_ids = [var.elk-sg, var.consul-agents-sg, var.node-exporter-sg]
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  user_data = data.template_cloudinit_config.consul_client.2.rendered


 
  tags = {
    Name = "kibana"
  }
  connection {
    host = aws_instance.kibana.private_ip
    user = "ubuntu"
    private_key = file("Mid-proj.pem")
    bastion_host        =  aws_instance.bastion.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("Mid-proj.pem")
  }

  provisioner "file" {
    source      = "../instances/templates/export.ndjson"
    destination = "/home/ubuntu/export.ndjson"
  }

 
 provisioner "remote-exec" {
    inline = [
      "curl -X POST 'localhost:5601/api/saved_objects/_import' -H 'kbn-xsrf: true' --form file=@export.ndjson"
    ]
  }
  

}