#!/usr/bin/env bash
sudo apt update
sudo apt-get install -y gnupg2 curl  software-properties-common
curl https://packages.grafana.com/gpg.key | sudo apt-key add -
sudo add-apt-repository 'deb https://packages.grafana.com/oss/deb stable main'
sudo apt-get update
sudo apt-get -y install grafana
sudo systemctl start grafana-server
until $(curl --output /dev/null --silent --head --fail http://admin:admin@localhost:3000/api/admin/stats); do
    printf '.'
    sleep 5
done
