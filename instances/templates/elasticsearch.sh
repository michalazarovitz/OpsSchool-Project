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

#Install consul
echo "Grabbing IPs..."
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

echo "Installing dependencies..."
sudo apt-get -q update
sudo apt-get -yq install unzip dnsmasq

echo "Configuring dnsmasq..."
cat << EODMCF >/etc/dnsmasq.d/10-consul
# Enable forward lookup of the 'consul' domain:
server=/consul/127.0.0.1#8600
EODMCF

sudo systemctl restart dnsmasq

cat << EOF >/etc/systemd/resolved.conf
[Resolve]
DNS=127.0.0.1
Domains=~consul
EOF

sudo systemctl restart systemd-resolved.service

echo "Fetching Consul..."
cd /tmp
curl -sLo consul.zip https://releases.hashicorp.com/consul/1.4.0/consul_1.4.0_linux_amd64.zip

echo "Installing Consul..."
sudo unzip consul.zip >/dev/null
sudo chmod +x consul
sudo mv consul /usr/local/bin/consul

# Setup Consul
sudo mkdir -p /opt/consul
sudo mkdir -p /etc/consul.d
sudo mkdir -p /run/consul
tee /etc/consul.d/config.json > /dev/null <<EOF
{
  "advertise_addr": "$PRIVATE_IP",
  "data_dir": "/opt/consul",
  "datacenter": "opsschool",
  "encrypt": "uDBV4e+LbFW3019YKPxIrg==",
  "disable_remote_exec": true,
  "disable_update_check": true,
  "leave_on_terminate": true,
  "retry_join": ["provider=aws tag_key=consul_server tag_value=true"],
  "node_name": "elasticsearch",
  "enable_script_checks": true,
  "server": false
}
EOF

# Create user & grant ownership of folders
sudo useradd consul
sudo chown -R consul:consul /opt/consul /etc/consul.d /run/consul


# Configure consul service
tee /etc/systemd/system/consul.service > /dev/null <<"EOF"
[Unit]
Description=Consul service discovery agent
Requires=network-online.target
After=network.target

[Service]
User=consul
Group=consul
PIDFile=/run/consul/consul.pid
Restart=on-failure
Environment=GOMAXPROCS=2
ExecStart=/usr/local/bin/consul agent -pid-file=/run/consul/consul.pid -config-dir=/etc/consul.d
ExecReload=/bin/kill -s HUP \$MAINPID
KillSignal=SIGINT
TimeoutStopSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable consul.service
sudo systemctl start consul.service


echo "Grabbing IPs..."
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

echo "Installing dependencies..."
sudo apt-get -q update


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

### Install Node Exporter
wget https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz -O /tmp/node_exporter.tgz
sudo mkdir -p /opt/prometheus
sudo tar zxf /tmp/node_exporter.tgz -C /opt/prometheus

# Configure node exporter service
tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Prometheus node exporter
Requires=network-online.target
After=network.target

[Service]
ExecStart=/opt/prometheus/node_exporter-0.18.1.linux-amd64/node_exporter
KillSignal=SIGINT
TimeoutStopSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable node_exporter.service
sudo systemctl start node_exporter.service
