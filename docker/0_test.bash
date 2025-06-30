wget https://desktop.docker.com/linux/main/arm64/187762/docker-desktop-arm64.deb
sudo apt install ./docker-desktop-arm64.deb

docker run -d \
  --name deepracer \
  --privileged \
  --network host \
  --cgroupns=host \
  -v /sys:/sys \
  -v /dev:/dev \
  -v /opt:/opt \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v /home/deepracer/Desktop/workspace:/workspace \
  -e DISPLAY=$DISPLAY \
  deepracer:latest \
  bash
