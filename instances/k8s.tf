resource "aws_instance" "k8s" {
  ami                    = var.ami
  instance_type          = "t2.micro"
  key_name = "Mid-proj"
  subnet_id= element(var.private_subnets.*.id,1)
  vpc_security_group_ids = [var.jenkins-sg]
  iam_instance_profile= aws_iam_instance_profile.eks_profile.name
  
  tags = {
    Name = "k8s"     
  }

  connection {
    host       = self.private_ip
    user        = "ubuntu"
    private_key = file("Mid-proj.pem")
    bastion_host        =  aws_instance.bastion.public_ip
    bastion_user        = "ubuntu"
    bastion_private_key = file("Mid-proj.pem")
  }

  provisioner "file" {
    source      = "../instances/k8sfiles"
    destination = "/home/ubuntu/"
  }
   
 provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install wget unzip -y",
      "sudo wget https://releases.hashicorp.com/terraform/0.12.18/terraform_0.12.18_linux_amd64.zip",
      "sudo unzip terraform_0.12.18_linux_amd64.zip",
      "sudo mv terraform /usr/local/bin/",
      "sudo curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl",
      "sudo chmod +x ./kubectl",
      "sudo mv ./kubectl /usr/local/bin/kubectl",
      "curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/aws-iam-authenticator",
      "sudo chmod +x ./aws-iam-authenticator",
      "mkdir bin",
      "cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$HOME/bin:$PATH",
      "sudo echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc",
      "sudo apt-get update -y",
      "sudo apt-get install python3-pip -y",
      "sudo pip3 install --upgrade awscli",
      "mkdir .aws",
      "cd k8sfiles",
      "mv config /home/ubuntu/.aws/",
      "mv credentials /home/ubuntu/.aws/",
      "mv eks.tf /home/ubuntu/",
      "cd ..",
      "sudo sed -i 's/midprojvpcid/${var.vpc_id}/' eks.tf",
      "terraform init",
      "terraform plan",
      "terraform apply --auto-approve",
      "aws eks update-kubeconfig --name opsSchool-eks-flask-app",
      "sudo chmod +x /home/ubuntu/k8sfiles/install-helm.sh",
      "./k8sfiles/install-helm.sh"
        
            
    ]
  }


}  