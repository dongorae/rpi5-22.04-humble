#!/usr/bin/env bash

sudo apt update && sudo apt install -y python3-pip libgpiod2 libgpiod-dev fuse3
sudo pip3 install gpiod-sysfs-proxy