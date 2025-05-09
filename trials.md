# rpi5-22.04-humble

https://medium.com/@antonioconsiglio/how-to-install-ros2-humble-on-raspberry-pi-5-and-enable-communication-with-esp32-via-micro-ros-2d30dfcf2111


- 도커 설
```bash
sudo apt-get update

sudo apt-get install ca-certificates curl

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo   "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" |   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker $USER
```

```Dockerfile
FROM ros:humble
ARG USERNAME=deepracer
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN if id -u $USER_UID ; then userdel `id -un $USER_UID` ; fi

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y python3-pip
ENV SHELL /bin/bash

USER $USERNAME
CMD ["/bin/bash"]

```

```bash
xhost +local:root

docker run -itd \
  --privileged \
  --network host \
  --name deepracer \
  -v /dev:/dev \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  ros:humble
  ```


```bash
xhost +local:root

docker run -itd \
  --privileged \
  --network host \
  --name deepracer \
  --restart unless-stopped \
  -v /dev:/dev \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  ros:humble
  ```


```bash
xhost +local:root

docker run -d \
  --privileged \
  --network host \
  --cgroupns=host \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  -v /sys:/sys \
  -v /dev:/dev \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  --name deepracer \
  --restart unless-stopped \
  ros:humble \
  bash -c "apt-get update && apt-get install -y systemd systemd-sysv && exec /lib/systemd/systemd"


```

```dockerfile
FROM ros:humble
RUN apt-get update && apt-get install -y systemd systemd-sysv
CMD ["/lib/systemd/systemd"]
```

```bash
docker build -t deepracer:latest .
```

```bash
docker run -d \
  --name deepracer \
  --privileged \
  --network host \
  --cgroupns=host \
  -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
  -v /sys:/sys \
  -v /dev:/dev \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY=$DISPLAY \
  deepracer:latest
```

```bash
docker run -d \
  --name deepracer \
  --privileged \
  --network host \
  --cgroupns=host \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -e DISPLAY=$DISPLAY \
  deepracer:latest
```

```bash
docker exec -it deepracer /bin/bash
```

```bash
if docker ps --format '{{.Names}}' | grep -q '^deepracer$'; then
    echo "이미 실행 중입니다."
elif docker ps -a --format '{{.Names}}' | grep -q '^deepracer$'; then
    echo "멈춰 있던 컨테이너를 다시 시작합니다."
    docker start deepracer
else
    echo "새 컨테이너를 만듭니다."
  docker run -d \
    --name deepracer \
    --privileged \
    --network host \
    --cgroupns=host \
    -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
    -v /sys:/sys \
    -v /dev:/dev \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=$DISPLAY \
    deepracer:latest
fi
```


https://forums.docker.com/t/docker-image-is-missing-gpio-in-sys-class/141420/5


lib-gpio

gpio-sysfs

https://raspberrypi.stackexchange.com/questions/148769/troubleshooting-pwm-via-sysfs