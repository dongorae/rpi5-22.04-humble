## 1 단계 · 호스트(RPi 5) 쪽 설정

### A. 디바이스 오버레이

`/boot/firmware/config.txt`

```ini
# SoC 2채널 PWM (모터·서보)
dtoverlay=pwm-2chan             # GPIO18/PWM0  GPIO19/PWM1
dtoverlay=pwm,pin=13,func=4     # GPIO13/PWM2  (RGB enable)

# PCA9685 16‑채널 서보‑HAT를 I2C‑GPIO로 노출 → gpiochip base=488
dtoverlay=pca9685,addr=0x40,pin_base=488
#          └──── I2C 주소 (HAT 기본 0x40)
#                               └─ 예전 rpi4 빌드에서 썼던 base
```

### B. 필수 디바이스 패스스루

컨테이너를 띄울 때:

```bash
docker run --privileged \
    --name deepracer \
    --privileged \
    --network host \
    --cgroupns=host \
    --cap-add SYS_ADMIN \
    -v /sys/fs/cgroup:/sys/fs/cgroup:rw \
    -v /sys:/sys \
    -v /dev:/dev \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /home/deepracer/Desktop/workspace:/workspace \
    -e DISPLAY=$DISPLAY \
    deepracer:latest
```

### C. USB 툴

컨테이너 안에서:

```bash
apt-get update && apt-get install -y usbutils
```

## 2 단계 · 컨테이너 안 GPIO sysfs 프록시(gpiod‑sysfs‑proxy) 패치

```bash
git clone https://github.com/brgl/gpiod-sysfs-proxy
cd gpiod-sysfs-proxy
sed -i 's/BASE = 512/BASE = 0/' gpiod-sysfs-proxy
# 동일한 _add_chip() 패치 적용
python3 -m pip install .
```

## 3 단계 · 검증

```bash
# 1) 칩과 범위 확인
for c in /sys/class/gpio/gpiochip*; do
  echo "$c base=$(cat $c/base) ngpio=$(cat $c/ngpio)"
done
# 기대: base 0 / 352 / 488

# 2) 필수 라인 export
for n in 1 383 495 496 497 501 502 503; do
  echo $n | sudo tee /sys/class/gpio/export
done

# 3) 서보‑PWM 디렉터리도 존재?
ls /sys/class/pwm/pwmchip0
```

## 4 단계 · 딥레이서 스택 재기동

```bash
sudo /opt/aws/deepracer/start_ros.sh
```