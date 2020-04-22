#!/usr/bin/env bash
set -e

echo "Grabbing IPs..."
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

echo "Installing dependencies..."
sudo apt-get -q update


tee /etc/consul.d/mysql.json > /dev/null <<"EOF"
{
  "service": {
    "id": "mysql",
    "name": "mysql",
    "tags": ["opsschool"],
    "port": 3306,
    "checks": [
      {
        "id": "tcp",
        "name": "TCP on port 3306",
        "tcp": "localhost:3306",
        "interval": "10s",
        "timeout": "1s"
      },
      {
        "id": "service",
        "name": "mysql service",
        "args": ["systemctl", "status", "mysql.service"],
        "interval": "60s"
      }
    ]
  }
}
EOF

sudo consul reload

