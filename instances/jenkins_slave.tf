resource "aws_instance" "jenkins_slave" {
  depends_on= [aws_instance.k8s]
  ami = "ami-04590e7389a6e577c"
  instance_type = "t2.micro"
  key_name = "Mid-proj"
  subnet_id= element(var.public_subnets.*.id,0)
  vpc_security_group_ids = [var.jenkins-sg]
  
  
  tags = {
    Name = "jenkins_slave"
  }

   connection {
    type = "ssh"
    host = self.private_ip
    user = "ec2-user"
    private_key = file("Mid-proj.pem")
    bastion_host        =  aws_instance.bastion.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("Mid-proj.pem")
  }

   provisioner "file" {
    source      = "../instances/id_rsa.pub"
    destination = "/home/ec2-user/.ssh/id_rsa.pub"
  }

    provisioner "file" {
    source      = "../instances/Mid-proj.pem"
    destination = "/home/ec2-user/Mid-proj.pem"
  }

    provisioner "remote-exec" {
    inline = [
       "sudo yum update -y",
       "sudo yum install java-1.8.0 -y",
       "sudo alternatives --install /usr/bin/java java /usr/java/latest/bin/java 1",
       "sudo yum install docker git -y",
       "sudo service docker start",
       "sudo usermod -aG docker ec2-user",
       "sudo chmod 600 Mid-proj.pem",
       "cd .ssh",
       "sudo cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys",
       "sudo chmod 600 ~/.ssh/authorized_keys"
       
    ]
  }
}