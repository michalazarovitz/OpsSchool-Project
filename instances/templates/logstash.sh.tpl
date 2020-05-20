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
    hosts => ["elasticsearch.service.opsschool.consul:9200"]
  }
  stdout { codec => rubydebug }
}
EOF

sudo rm /etc/logstash/logstash-sample.conf
sudo systemctl restart logstash
sudo chown -R logstash.logstash /usr/share/logstash
sudo chmod 777 /usr/share/logstash/data

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

