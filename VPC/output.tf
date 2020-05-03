output "vpc_id" {
  value       = aws_vpc.midprojvpc.id
  description = "vpc id"
}

output "private_subnets" {
  value       = aws_subnet.private-subnets.*.id
  description = "The private subnets"
 }

output "ntgw" {
  value       = aws_nat_gateway.natgw.*.id
  description = "NAT gateway"
}

output "jenkins-sg" {
  value       = aws_security_group.jenkins-sg.id
  description = "jenkins-sg"
}

output "mysql-sg" {
  value       = aws_security_group.mysql-sg.id
  description = "mysql-sg"
}

output "consul-sg" {
  value       = aws_security_group.consul-sg.id
  description = "consul-sg"
}

output "bastion-sg" {
  value       = aws_security_group.bastion-sg.id
  description = "bastion-sg"
}

output "consul-agents-sg" {
  value       = aws_security_group.consul-agents-sg.id
  description = "consul-agents-sg"
}

output "prometheus-sg" {
  value       = aws_security_group.prometheus-sg.id
  description = "prometheus-sg"
}

output "grafana-sg" {
  value       = aws_security_group.grafana-sg.id
  description = "grafana-sg"
}

output "elk-sg" {
  value       = aws_security_group.elk-sg.id
  description = "elk-sg"
}

