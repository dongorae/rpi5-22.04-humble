wget https://desktop.docker.com/linux/main/arm64/187762/docker-desktop-arm64.deb
sudo apt install ./docker-desktop-arm64.deb

sudo docker run -d \
  --name deepracer \
  --restart unless-stopped \
  --privileged \
  --network host \
  --cgroupns=host \
  -v /sys:/sys \
  -v /dev:/dev \
  -v /opt:/opt \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY=$DISPLAY \
  physicar/deepracer:latest

DEBIAN_FRONTEND=noninteractive \
  apt-get install -y sudo git usbutils systemd systemd-sysv
