FROM ros:humble

# 1) 패키지 설치 (systemd + GPIO/FUSE + pip)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        systemd systemd-sysv \
        python3-pip \
        libgpiod2 libgpiod-dev \
        fuse3 && \
    pip3 install --no-cache-dir gpiod-sysfs-proxy && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# 2) systemd가 PID 1 로 뜨기 전에 GPIO‑sysfs overlay 를 준비할 스크립트
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
