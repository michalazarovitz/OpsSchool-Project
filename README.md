# OpsSchool-Project

## Overview
Opsschool final project deploy a highly available web application on AWS using:
- AWS - Cloud Provider
- Kubernetes - Container Orchestration Engine
- Ansible - Configuration Management
- Terraform - IaC
- Jenkins - CI/CD
- Consul - Service Discovery
- Prometheus, Grafana - Monitoring
- ELK - Logging

## AWS infrastructure
Automated with Terraform and Ansible.
- VPC with public and private subnets in two different availability zones, internet gateway ,route tables, elastic IP and NAT gateway for both private subnets.
- EKS cluster
- Bastion host
- 3 Consul servers
- Jenkins Master & Slave
- MySQL server
- Prometheus & Grafana servers
- Logstash, Elasticsearch and Kibana servers
- Load Balancers to enable public access

<img width="498" alt="project-infrastructure" src="https://user-images.githubusercontent.com/55147076/83349910-dda47b00-a340-11ea-8703-639ab4f2e593.png">

## CI/CD
2 Pipelines:
- database deployment
- application deployment

## Kubernetes
Managed EKS cluster with worker nodes in private subnets. Used for deploying and managing my containerized application.

## Monitoring
2 Prometheus servers - one per Kubernetes cluster and one per project's hosts.
Both Prometheus servers connected to one Grafana server with custom dashboards.

## Logging
Shipping system logs and logs from Kubernetes and MySQL to Logstash using Filebeat.
Then sending the processed data to Elasticsearch and visualize the data in Kibana with custom dashboard.

