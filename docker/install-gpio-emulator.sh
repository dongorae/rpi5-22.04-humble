#!/usr/bin/env bash

sudo apt update
sudo apt install -y python3-pip libgpiod2 libgpiod-dev fuse3
sudo python3 -m pip config set global.break-system-packages true
sudo pip3 install gpiod-sysfs-proxy`