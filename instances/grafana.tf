resource "aws_instance" "grafana" {
  ami           = var.ami
  instance_type = "t2.micro"
  key_name      = var.key_name
  subnet_id = element(var.public_subnets.*.id, 0)
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  vpc_security_group_ids = [var.consul-sg]
  user_data = data.template_cloudinit_config.consul_client.3.rendered

 
  tags = {
    Name = "grafana"
  }

 connection {
    host = aws_instance.grafana.public_ip
    user = "ubuntu"
    private_key = file("Mid-proj.pem")
    bastion_host        =  aws_instance.bastion.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("Mid-proj.pem")
  }

 
 provisioner "remote-exec" {
    inline = [
      "sudo apt update",
      "sudo apt-get install -y gnupg2 curl  software-properties-common",
      "curl https://packages.grafana.com/gpg.key | sudo apt-key add -",
      "sudo add-apt-repository 'deb https://packages.grafana.com/oss/deb stable main'",
      "sudo apt-get update",
      "sudo apt-get -y install grafana",
      "sudo systemctl start grafana-server"
    
    ]
  }

}


provider "grafana" {
  url  = "http://${aws_instance.grafana.private_ip}:3000"
  auth = "admin:admin"
}

resource "grafana_data_source" "prometheus" {
  type       = "prometheus"
  name       = "prometheus"
  url        = "http://${aws_instance.promcol.private_ip}:9090"
  is_default = true
}

resource "grafana_dashboard" "node-exporter" {
  config_json = "${file("${path.module}/templates/node-exporter.json")}"
}

