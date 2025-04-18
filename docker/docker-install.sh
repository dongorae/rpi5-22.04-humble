#!/usr/bin/env bash

# set -e            
# export DEBIAN_FRONTEND=noninteractive  

# ---------------- Docker 저장소 추가 ----------------
sudo apt-get update -y
sudo apt-get install -y ca-certificates curl

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
| sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# ---------------- Docker 패키지 설치 ----------------
sudo apt-get update -y
sudo apt-get install -y \
    docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin

# ---------------- 현재 사용자 docker 그룹 추가 ----------------
sudo usermod -aG docker "$USER"