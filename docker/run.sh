#!/bin/bash

docker run -d \
    --name deepracer \
    --restart unless-stopped \
    --privileged \
    --network host \
    --cgroupns=host \
    -v /sys:/sys \
    -v /dev:/dev \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /home/deepracer/Desktop/workspace:/workspace \
    -e DISPLAY=$DISPLAY \
    deepracer:latest