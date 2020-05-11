# Create an IAM role for the auto-join
resource "aws_iam_role" "consul-join" {
  name               = "opsschool-consul-join"
  assume_role_policy = file("${path.module}/templates/policies/assume-role.json")
}

# Create the policy
resource "aws_iam_policy" "consul-join" {
  name        = "opsschool-consul-join"
  description = "Allows Consul nodes to describe instances for joining."
  policy      = file("${path.module}/templates/policies/describe-instances.json")
}

# Attach the policy
resource "aws_iam_policy_attachment" "consul-join" {
  name       = "opsschool-consul-join"
  roles      = ["${aws_iam_role.consul-join.name}"]
  policy_arn = aws_iam_policy.consul-join.arn
}

# Create the instance profile
resource "aws_iam_instance_profile" "consul-join" {
  name  = "opsschool-consul-join"
  role = aws_iam_role.consul-join.name
}


data "template_file" "consul_client" {
  count    = length(var.consul_agents)
  template = file("${path.module}/templates/consul.sh.tpl")

  vars = {
      consul_version = var.consul_version
      config = <<EOF
       "node_name": "${element(var.consul_agents,count.index)}",
       "enable_script_checks": true,
       "server": false
      EOF
  }
}

# Create the user-data for the Consul agent
data "template_cloudinit_config" "consul_client" {
  count    = length(var.consul_agents)
  part {
    content = element(data.template_file.consul_client.*.rendered, count.index)

  }
  part {
    content = file("${path.module}/templates/${element(var.consul_agents,count.index)}.sh.tpl")
  }

  part {
    content = file("${path.module}/templates/install-node-exporter.sh")
  }

  part {
    content = file("${path.module}/templates/install-filebeat.sh")
  }
}

# Create the user-data for the Consul server
data "template_file" "consul_server" {
  count    = var.servers
  template = file("${path.module}/templates/consul.sh.tpl")

  vars = {
    consul_version = var.consul_version
    node_exporter_version = var.node_exporter_version
    prometheus_dir = var.prometheus_dir
    config = <<EOF
     "node_name": "opsschool-server-${count.index+1}",
     "server": true,
     "bootstrap_expect": 3,
     "ui": true,
     "client_addr": "0.0.0.0",
     "telemetry": {
     "prometheus_retention_time": "10m"
     }
    EOF
  }
}

data "template_cloudinit_config" "consul_servers" {
  count    = var.servers
  part {
    content = element(data.template_file.consul_server.*.rendered, count.index)
  }
  part {
    content = file("${path.module}/templates/install-node-exporter.sh")
  }
  part {
    content = file("${path.module}/templates/install-filebeat.sh")
  }
  part {
    content = file("${path.module}/templates/install-consul-exporter.sh")
  }
}


# Create the Consul cluster
resource "aws_instance" "consul_server" {
  count = var.servers
  associate_public_ip_address = false
  ami           = var.ami
  instance_type = "t2.micro"
  key_name      = var.key_name
  subnet_id = element(var.private_subnets.*.id, count.index)
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  vpc_security_group_ids = [var.consul-sg, var.node-exporter-sg]
  user_data = element(data.template_cloudinit_config.consul_servers.*.rendered, count.index)

  tags = {
    Name = "consul-server-${count.index+1}"
    consul_server = "true"
  }

  
}



