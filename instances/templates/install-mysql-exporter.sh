#!/usr/bin/env bash
set -e

### Install MySQL Exporter
wget https://github.com/prometheus/mysqld_exporter/releases/download/v0.11.0/mysqld_exporter-0.11.0.linux-amd64.tar.gz -O /tmp/mysqld_exporter.tgz
sudo tar zxf /tmp/mysqld_exporter.tgz -C /opt/prometheus

# Configure MySQL exporter credentials
sudo tee /etc/.mysqld_exporter.cnf > /dev/null <<EOF
[client]
user=mysqld_exporter
password=mysqld_exporter
EOF
sudo chown root: /etc/.mysqld_exporter.cnf

# Configure MySQL exporter service
sudo tee /etc/systemd/system/mysql_exporter.service > /dev/null <<EOF
[Unit]
Description=Prometheus mysql exporter
Requires=network-online.target
After=network.target
[Service]
ExecStart=/opt/prometheus/mysqld_exporter-0.11.0.linux-amd64/mysqld_exporter \
--config.my-cnf /etc/.mysqld_exporter.cnf \
--collect.global_status \
--collect.info_schema.innodb_metrics \
--collect.auto_increment.columns \
--collect.info_schema.processlist \
--collect.binlog_size \
--collect.info_schema.tablestats \
--collect.global_variables \
--collect.info_schema.query_response_time \
--collect.info_schema.userstats \
--collect.info_schema.tables \
--collect.perf_schema.tablelocks \
--collect.perf_schema.file_events \
--collect.perf_schema.eventswaits \
--collect.perf_schema.indexiowaits \
--collect.perf_schema.tableiowaits \
--collect.slave_status \
--web.listen-address=0.0.0.0:9104
KillSignal=SIGINT
TimeoutStopSec=5
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable mysql_exporter.service
sudo systemctl start mysql_exporter.service