#!/usr/bin/env bash
set -e

## Install consul exporter
wget https://github.com/prometheus/consul_exporter/releases/download/v0.3.0/consul_exporter-0.3.0.linux-amd64.tar.gz -O /tmp/consul_exporter.tgz
sudo tar zxf /tmp/consul_exporter.tgz -C /opt/prometheus

# Configure consul exporter service
tee /etc/systemd/system/consul_exporter.service > /dev/null <<EOF
[Unit]
Description=Prometheus consul exporter
Requires=network-online.target
After=network.target
[Service]
ExecStart=/opt/prometheus/consul_exporter-0.3.0.linux-amd64/consul_exporter
KillSignal=SIGINT
TimeoutStopSec=5
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable consul_exporter.service
sudo systemctl start consul_exporter.service