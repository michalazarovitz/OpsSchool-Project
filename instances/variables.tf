variable "vpc_id" {}
variable "private_subnets" {}
variable "public_subnets" {}
variable "ntgw" {}
variable "jenkins-sg" {}
variable "mysql-sg" {}
variable "consul-sg" {}
variable "bastion-sg" {}
variable "consul-agents-sg" {}
variable "prometheus-sg" {}
variable "grafana-sg" {}
variable "elk-sg" {}

variable "region" {
  description = "AWS region for VMs"
  default = "us-west-2"
}

variable "servers" {
  description = "The number of consul servers."
  default = 3
}

variable "consul_agents" {
  description = "consul agents"
  default = ["logstash", "elasticsearch", "kibana", "mysql", "promcol", "grafana" ,"jenkins"]
}


variable "consul_version" {
  description = "The version of Consul to install (server and client)."
  default     = "1.4.0"
}

variable "key_name" {
  description = "name of ssh key to attach to hosts"
  default = "Mid-proj"
}

variable "ami" {
  description = "ami to use - based on region"
  default = "ami-0d1cd67c26f5fca19"
  
}

variable "prometheus_dir" {
  description = "directory for prometheus binaries"
  default = "/opt/prometheus"
}

variable "prometheus_conf_dir" {
  description = "directory for prometheus configuration"
  default = "/etc/prometheus"
}

variable "promcol_version" {
  description = "Prometheus Collector version"
  default = "2.16.0"
}

variable "node_exporter_version" {
  description = "Node Exporter version"
  default = "0.18.1"
}
