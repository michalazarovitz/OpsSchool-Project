#!/usr/bin/env bash
set -e

echo "Grabbing IPs..."
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

echo "Installing dependencies..."
sudo apt-get -q update

tee /etc/consul.d/jenkins.json > /dev/null <<"EOF"
{
  "service": {
    "id": "jenkins",
    "name": "jenkins",
    "tags": ["opsschool"],
    "port": 8080,
    "checks": [
      {
        "id": "tcp",
        "name": "TCP on port 8080",
        "tcp": "localhost:8080",
        "interval": "10s",
        "timeout": "1s"
      },
      {
        "id": "http",
        "name": "HTTP on port 8080",
        "http": "http://localhost:8080/",
        "interval": "30s",
        "timeout": "1s"
      },
      {
        "id": "service",
        "name": "jenkins service",
        "args": ["systemctl", "status", "jenkins.service"],
        "interval": "60s"
      }
    ]
  }
}
EOF

sudo consul reload

