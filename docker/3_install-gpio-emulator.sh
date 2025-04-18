#!/usr/bin/env bash

sudo apt update
sudo apt install -y python3-pip git libgpiod2 libgpiod-dev fuse3
sudo python3 -m pip config set global.break-system-packages true

# sudo pip3 install gpiod-sysfs-proxy
cd ~
git clone https://github.com/brgl/gpiod-sysfs-proxy
cd gpiod-sysfs-proxy
sed -i 's/BASE = 512/BASE = 437/' gpiod-sysfs-proxy
sudo python3 -m pip install -e .