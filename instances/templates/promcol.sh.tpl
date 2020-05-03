#!/usr/bin/env bash
set -e

### Install Prometheus Collector
wget https://github.com/prometheus/prometheus/releases/download/v2.16.0/prometheus-2.16.0.linux-amd64.tar.gz -O /tmp/promcoll.tgz
sudo mkdir -p /opt/prometheus
sudo tar zxf /tmp/promcoll.tgz -C /opt/prometheus

# Create promcol configuration
sudo mkdir -p /etc/prometheus
tee /etc/prometheus/prometheus.yml > /dev/null <<EOF
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
    - targets: ['localhost:9090']

  - job_name: 'node-exporter'
    consul_sd_configs:
      - server: 'localhost:8500'
    # All hosts detected will use port 9100 for node-exporter
    relabel_configs:
      - source_labels: ['__address__']
        separator:     ':'
        regex:         '(.*):(.*)'
        target_label:  '__address__'
        replacement:   '\$1:9100'
      - source_labels: [__meta_consul_node]
        target_label: instance
      - source_labels: [__meta_consul_tags]
        regex: .*,k8s,.*
        action: drop           
EOF

# Configure promcol service
tee /etc/systemd/system/promcol.service > /dev/null <<EOF
[Unit]
Description=Prometheus Collector
Requires=network-online.target
After=network.target

[Service]
ExecStart=/opt/prometheus/prometheus-2.16.0.linux-amd64/prometheus --config.file=/etc/prometheus/prometheus.yml
ExecReload=/bin/kill -s HUP \$MAINPID
KillSignal=SIGINT
TimeoutStopSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable promcol.service
sudo systemctl start promcol.service

### add promcol service to consul
tee /etc/consul.d/promcol-9090.json > /dev/null <<"EOF"
{
  "service": {
    "id": "promcol-9090",
    "name": "promcol",
    "tags": ["opsschool"],
    "port": 9090,
    "checks": [
      {
        "id": "tcp",
        "name": "TCP on port 9090",
        "tcp": "localhost:9090",
        "interval": "10s",
        "timeout": "1s"
      }
    ]
  }
}
EOF

sudo consul reload

