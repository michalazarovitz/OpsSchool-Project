output "jenkins_master_ip" {
  value       = aws_instance.jenkins_master.private_ip
}

output "jenkins_slave_ip" {
  value       = aws_instance.jenkins_slave.private_ip
}

output "servers" {
  value = aws_instance.consul_server.*.private_ip
}
