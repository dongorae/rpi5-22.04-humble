#!/bin/bash
if ! mountpoint -q /sys/class/gpio; then
    sudo mkdir -p /run/gpio/sys /run/gpio/class/gpio /run/gpio/work
    sudo mount -t sysfs sysfs /run/gpio/sys
    sudo mount -t overlay overlay -o lowerdir=/run/gpio/sys/class,upperdir=/run/gpio/class,workdir=/run/gpio/work /sys/class
    sudo gpiod-sysfs-proxy /sys/class/gpio -o nonempty -o allow_other -o default_permissions -o entry_timeout=0
fi

