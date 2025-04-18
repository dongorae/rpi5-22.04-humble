#!/bin/bash

sudo pkill -f "gpiod-sysfs-proxy /sys/class/gpio" 2>/dev/null

sudo fusermount -u /sys/class/gpio        2>/dev/null
sudo umount /sys/class                    2>/dev/null
sudo umount /run/gpio/sys                 2>/dev/null
