resource "aws_instance" "grafana" {
  ami           = var.ami
  instance_type = "t2.micro"
  key_name      = var.key_name
  subnet_id = element(var.public_subnets.*.id, 0)
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  vpc_security_group_ids = [var.grafana-sg, var.consul-agents-sg]
  user_data = data.template_cloudinit_config.consul_client.5.rendered

 
  tags = {
    Name = "grafana"
  }

 connection {
    host = aws_instance.grafana.public_ip
    user = "ubuntu"
    private_key = file("Mid-proj.pem")
  }

  provisioner "file" {
    source      = "../instances/templates/install_grafana.sh"
    destination = "/tmp/install_grafana.sh"
  }


 
 provisioner "remote-exec" {
    inline = [
      "sudo chmod +x /tmp/install_grafana.sh",
      "/tmp/install_grafana.sh"
    ]
  }

}

provider "grafana" {
  url  = "http://${aws_instance.grafana.public_ip}:3000"
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

