#!/bin/bash
set -e

#Install elasricsearch
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.6.2-amd64.deb
sudo dpkg -i elasticsearch-7.6.2-amd64.deb
sudo systemctl daemon-reload 
sudo systemctl enable elasticsearch.service
sudo systemctl start elasticsearch.service
sudo adduser ubuntu elasticsearch
sudo chmod +x /usr/share/elasticsearch/bin/elasticsearch
sudo chown -R ubuntu:elasticsearch /etc/elasticsearch
sudo echo 'network.bind_host: 0.0.0.0' >> /etc/elasticsearch/elasticsearch.yml
sudo echo 'node.name: node-1' >> /etc/elasticsearch/elasticsearch.yml
sudo echo 'cluster.initial_master_nodes: node-1' >> /etc/elasticsearch/elasticsearch.yml
sudo systemctl restart elasticsearch.service

#Add consul service
tee /etc/consul.d/elasticsearch.json > /dev/null <<"EOF"
{
  "service": {
    "id": "elasticsearch",
    "name": "elasticsearch",
    "tags": ["opsschool"],
    "port": 9200,
    "checks": [
      {
        "id": "tcp",
        "name": "TCP on port 9200",
        "tcp": "localhost:9200",
        "interval": "10s",
        "timeout": "1s"
      },
      {
        "id": "service",
        "name": "elasticsearch service",
        "args": ["systemctl", "status", "elasticsearch.service"],
        "interval": "60s"
      }
    ]
  }
}
EOF

sudo consul reload

