#!/usr/bin/env bash
set -e


echo "Grabbing IPs..."
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

echo "Installing dependencies..."
sudo apt-get -q update

tee /etc/consul.d/grafana.json > /dev/null <<"EOF"
{
  "service": {
    "id": "grafana",
    "name": "grafana",
    "tags": ["opsschool"],
    "port": 3000,
    "checks": [
      {
        "id": "tcp",
        "name": "TCP on port 3000",
        "tcp": "localhost:3000",
        "interval": "10s",
        "timeout": "1s"
      },
      {
        "id": "http",
        "name": "HTTP on port 3000",
        "http": "http://localhost:3000/",
        "interval": "30s",
        "timeout": "1s"
      },
      {
        "id": "service",
        "name": "grafana service",
        "args": ["systemctl", "status", "grafana-server.service"],
        "interval": "60s"
      }
    ]
  }
}
EOF

sudo consul reload