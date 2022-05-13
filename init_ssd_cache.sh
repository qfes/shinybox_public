#! /usr/bin/bash

SSD=`sudo -E nvme list -o "json" | jq '.Devices | map(select(.ModelNumber=="Amazon Elastic Block Store")) | .[0].DevicePath' | tr -d '"'`
sudo mkfs -t xfs ${SSD}
sudo mount ${SSD} /ssd
sudo chmod 777 /ssd

export SHINYBOX_SHINY_CACHE=/ssd
