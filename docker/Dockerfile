FROM ubuntu:24.04

# 1) 빌드 단계 전체에 적용
ENV DEBIAN_FRONTEND=noninteractive

# 2) 필요한 패키지 설치
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        usbutils systemd systemd-sysv && \
    rm -rf /var/lib/apt/lists/*

# systemd 컨테이너 권장 설정
STOPSIGNAL SIGRTMIN+3
CMD ["/lib/systemd/systemd"]
