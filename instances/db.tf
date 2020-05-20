resource "aws_instance" "db" {
  ami = var.ami
  instance_type = "t2.micro"
  key_name = "Mid-proj"
  subnet_id= element(var.private_subnets.*.id,1)
  associate_public_ip_address= false
  vpc_security_group_ids = [var.mysql-sg, var.consul-agents-sg, var.node-exporter-sg]
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  user_data = data.template_cloudinit_config.consul_client.3.rendered

   
  tags = {
    Name = "Mysql server"
  }

  connection {
    host = aws_instance.db.private_ip
    user = "ubuntu"
    private_key = file("Mid-proj.pem")
    bastion_host        =  aws_instance.bastion.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("Mid-proj.pem")
  }

  provisioner "file" {
    source      = "../instances/templates/install-mysql-exporter.sh"
    destination = "/tmp/install-mysql-exporter.sh"
  }

  provisioner "file" {
    source      = "../instances/templates/configure-mysql-logs.sh"
    destination = "/tmp/configure-mysql-logs.sh"
  }  


 
 provisioner "remote-exec" {
    inline = [
      "cloud-init status --wait",
      "sudo chmod +x /tmp/install-mysql-exporter.sh",
      "/tmp/install-mysql-exporter.sh",
      "sudo chmod +x /tmp/configure-mysql-logs.sh",
      "/tmp/configure-mysql-logs.sh"
    ]
  }
  
}