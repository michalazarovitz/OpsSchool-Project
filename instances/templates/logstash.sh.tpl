#!/usr/bin/env bash
set -e

#install java
sudo apt update -y
sudo apt install openjdk-11-jdk -y htop

#Install Logstash
sudo wget https://artifacts.elastic.co/downloads/logstash/logstash-7.6.2.deb
sudo dpkg -i logstash-7.6.2.deb

sudo chown -R ubuntu:ubuntu /etc/logstash/
sudo echo 'http.host: 0.0.0.0' >> /etc/logstash/logstash.yml

sudo systemctl daemon-reload
sudo systemctl enable logstash
sudo systemctl start logstash

 sudo /usr/share/logstash/bin/logstash-plugin install logstash-input-beats

# Create logstash configuration
sudo mkdir -p /etc/logstash/conf.d
sudo tee /etc/logstash/conf.d/beats.conf > /dev/null <<EOF
input {
  beats {
    port => "5044"
  }
}
output {
  elasticsearch {
    hosts => ["${elasticsearch_host}:9200"]
  }
  stdout { codec => rubydebug }
}
EOF

sudo rm /etc/logstash/logstash-sample.conf
sudo systemctl restart logstash
sudo chown -R logstash.logstash /usr/share/logstash
sudo chmod 777 /usr/share/logstash/data


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
  "node_name": "logstash",
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


tee /etc/consul.d/logstash.json > /dev/null <<"EOF"
{
  "service": {
    "id": "logstash",
    "name": "logstash",
    "tags": ["opsschool"],
    "port": 5044,
    "checks": [
      {
        "id": "tcp",
        "name": "TCP on port 5044",
        "tcp": "localhost:5044",
        "interval": "10s",
        "timeout": "1s"
      },
      {
        "id": "service",
        "name": "logstash service",
        "args": ["systemctl", "status", "logstash.service"],
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
