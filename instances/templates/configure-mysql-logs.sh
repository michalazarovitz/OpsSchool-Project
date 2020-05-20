#!/usr/bin/env bash
set -e

#filebeat modules enable mysql
sudo tee /etc/filebeat/filebeat.yml > /dev/null <<EOF
filebeat.inputs:
- input_type: log
  paths:
    - /var/log/syslog  

- input_type: log
  paths:
    - /var/log/mysql/mysql.log

output.logstash:
  hosts: ["logstash.service.opsschool.consul:5044"]

EOF
sudo systemctl restart filebeat
