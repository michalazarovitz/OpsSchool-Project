resource "aws_instance" "jenkins_master" {
  depends_on= [aws_instance.jenkins_slave]
  ami = var.ami
  instance_type = "t2.micro"
  key_name = "Mid-proj"
  subnet_id= element(var.private_subnets.*.id,1)
  vpc_security_group_ids = [var.jenkins-sg, var.consul-agents-sg]
  iam_instance_profile   = aws_iam_instance_profile.consul-join.name
  user_data = data.template_cloudinit_config.consul_client.6.rendered
   
  tags = {
    Name = "jenkins_master"
  }

   connection {
    host = aws_instance.jenkins_master.private_ip
    user = "ubuntu"
    private_key = file("Mid-proj.pem")
    bastion_host        =  aws_instance.bastion.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("Mid-proj.pem")
  }

  provisioner "file" {
    source      = "../instances/yamlfiles"
    destination = "/home/ubuntu/"
  }
   provisioner "remote-exec" {
    inline = [
       "cloud-init status --wait",
       "sudo apt update -y",
		   "sudo apt install software-properties-common -y",
	     "sudo apt-add-repository --yes --update ppa:ansible/ansible",
		   "sudo apt install ansible -y",
       "cd /home/ubuntu/yamlfiles/midproj_pipeline",
       "sed -i 's/k8sipadress/${aws_instance.k8s.private_ip}/' config.xml",
       "cd ..",
       "sudo chmod 600 Mid-proj.pem",
       "echo '[dbserver]' > inventory",
       "echo '${aws_instance.db.private_ip}' >> inventory",
       "ansible-playbook -i inventory mysql.yml --private-key Mid-proj.pem --ssh-common-args='-o StrictHostKeyChecking=no' -e 'ansible_python_interpreter=/usr/bin/python3'",
       "ansible-playbook install-jenkins.yml --extra-vars mysqlhost=${aws_instance.db.private_ip}",
       "ansible-playbook configure-slave.yml --extra-vars jenkins_slave_ip=${aws_instance.jenkins_slave.private_ip}"
      ]
     
  }

  

  
}