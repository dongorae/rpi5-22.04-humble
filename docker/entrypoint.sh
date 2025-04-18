#!/bin/bash

# set -e

# ---------- GPIO sysfs overlay (/sys/class/gpio 노출) ----------
mkdir -p /run/gpio/sys                \
         /run/gpio/class/gpio         \
         /run/gpio/work

# 원본 sysfs 를 별도 위치로 마운트
mount -t sysfs sysfs /run/gpio/sys

# overlayfs 로 /sys/class/* 를 덮어쓰기
mount -t overlay overlay \
      -o lowerdir=/run/gpio/sys/class,\
upperdir=/run/gpio/class,\
workdir=/run/gpio/work /sys/class

# FUSE 기반 gpiod‑sysfs‑proxy 실행 (백그라운드)
gpiod-sysfs-proxy /sys/class/gpio \
    -o nonempty \
    -o allow_other \
    -o default_permissions \
    -o entry_timeout=0 &

# ---------- systemd 부팅 ----------
exec /lib/systemd/systemd           # PID 1 교체
