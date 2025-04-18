# gpiod-sysfs-proxy

- rpi5 방식의 gpio 를 rpi4 방식의 gpio 로 에뮬레이션

<https://github.com/brgl/gpiod-sysfs-proxy>

- 설치
```bash
sudo apt update && sudo apt install -y python3-pip libgpiod2 libgpiod-dev fuse3
sudo pip3 install gpiod-sysfs-proxy
```

- 실행
```bash
#!/bin/bash
if ! mountpoint -q /sys/class/gpio; then
sudo mkdir -p /run/gpio/sys /run/gpio/class/gpio /run/gpio/work
sudo mount -t sysfs sysfs /run/gpio/sys
sudo mount -t overlay overlay -o lowerdir=/run/gpio/sys/class,upperdir=/run/gpio/class,workdir=/run/gpio/work /sys/class
sudo gpiod-sysfs-proxy /sys/class/gpio -o nonempty -o allow_other -o default_permissions -o entry_timeout=0
fi
```

