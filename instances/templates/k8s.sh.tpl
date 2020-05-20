#!/usr/bin/env bash
set -e


echo "Grabbing IPs..."
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

echo "Installing dependencies..."
sudo apt-get -q update

tee /etc/consul.d/k8s.json > /dev/null <<"EOF"
{
  "service": {
    "id": "k8s",
    "name": "k8s",
    "tags": ["opsschool"],
    "port": 8080,
    "checks": [
      {
        "id": "tcp",
        "name": "TCP on port 8080",
        "tcp": "localhost:8080",
        "interval": "10s",
        "timeout": "1s"
      }
      
    ]
  }
}
EOF

sudo consul reload