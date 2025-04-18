#!/bin/bash

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
        -v /sys:/sys \
        -v /dev:/dev \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v /home/deepracer/Desktop/workspace:/workspace \
        -e DISPLAY=$DISPLAY \
        deepracer:latest
fi