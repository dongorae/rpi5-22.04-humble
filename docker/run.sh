#!/bin/bash

docker run -d \
    --name deepracer \
    --restart unless-stopped \
    --privileged \
    --network host \
    --cgroupns=host \
    -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
    -v /sys:/sys \
    -v /dev:/dev \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -e DISPLAY=$DISPLAY \
    deepracer:latest