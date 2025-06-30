wget https://desktop.docker.com/linux/main/arm64/187762/docker-desktop-arm64.deb
sudo apt install ./docker-desktop-arm64.deb

sudo docker run -itd \
  --name deepracer \
  --restart unless-stop \
  --privileged \
  --network host \
  --cgroupns=host \
  -v /sys:/sys \
  -v /dev:/dev \
  -v /opt:/opt \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY=$DISPLAY \
  physicar/deepracer:latest \
  bash
