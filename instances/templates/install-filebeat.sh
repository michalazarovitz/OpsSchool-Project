#!/usr/bin/env bash
set -e

#Install filebeat
sudo curl -L -O https://artifacts.elastic.co/downloads/beats/filebeat/filebeat-7.6.2-amd64.deb
sudo dpkg -i filebeat-7.6.2-amd64.deb

sudo systemctl enable filebeat
sudo systemctl start filebeat

# Create filebeat configuration
sudo mkdir -p /etc/filebeat
tee /etc/filebeat/filebeat.yml > /dev/null <<EOF
filebeat.inputs:
- input_type: log
  paths:
    - /var/log/syslog  

output.logstash:
  hosts: ["logstash.service.opsschool.consul:5044"]

EOF

sudo systemctl restart filebeat