#!/bin/bash
set -e

#Install kibana
wget https://artifacts.elastic.co/downloads/kibana/kibana-7.6.2-amd64.deb
sudo dpkg -i kibana-7.6.2-amd64.deb
sudo systemctl daemon-reload 
sudo systemctl enable kibana.service
sudo systemctl start kibana.service
sudo adduser ubuntu kibana
sudo chmod +x /usr/share/kibana/bin/kibana
sudo chown -R ubuntu:kibana /etc/kibana
sudo echo 'server.port: 5601' >> /etc/kibana/kibana.yml
sudo echo 'server.host: 0.0.0.0' >> /etc/kibana/kibana.yml
sudo echo 'elasticsearch.hosts: ["http://elasticsearch.service.opsschool.consul:9200"]' >> /etc/kibana/kibana.yml
sudo systemctl restart kibana.service


tee /etc/consul.d/kibana.json > /dev/null <<"EOF"
{
  "service": {
    "id": "kibana",
    "name": "kibana",
    "tags": ["opsschool"],
    "port": 5601,
    "checks": [
      {
        "id": "tcp",
        "name": "TCP on port 5601",
        "tcp": "localhost:5601",
        "interval": "10s",
        "timeout": "1s"
      },
      {
        "id": "service",
        "name": "kibana service",
        "args": ["systemctl", "status", "kibana.service"],
        "interval": "60s"
      }
    ]
  }
}
EOF

sudo consul reload

