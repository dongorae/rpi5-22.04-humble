


## 1 단계 · 호스트(RPi 5) 쪽 설정  

### A. 디바이스 오버레이  

`/boot/firmware/config.txt`

- SoC 2채널 PWM 사용	dtoverlay=pwm-2chan
- PWM2 (GPIO13 → LED enable 용도)	dtoverlay=pwm,pin=13,func=4
- PCA9685 GPIO 확장칩	dtoverlay=pca9685,addr=0x40,pin_base=488

```ini
[all]
arm_64bit=1
kernel=vmlinuz
cmdline=cmdline.txt
initramfs initrd.img followkernel

# Enable the audio output, I2C and SPI interfaces on the GPIO header. As these
# parameters related to the base device-tree they must appear *before* any
# other dtoverlay= specification
dtparam=audio=on
dtparam=i2c_arm=on
dtparam=spi=on

# --- PWM 및 GPIO 확장 칩 설정 (추가) ---
dtoverlay=dwc2
dtoverlay=i2c-pwm-pca9685a,addr=0x40

# Comment out the following line if the edges of the desktop appear outside
# the edges of your display
disable_overscan=1

# If you have issues with audio, you may try uncommenting the following line
# which forces the HDMI output into HDMI mode instead of DVI (which doesn't
# support audio output)
#hdmi_drive=2

# Enable the KMS ("full" KMS) graphics overlay, leaving GPU memory as the
# default (the kernel is in control of graphics memory with full KMS)
dtoverlay=vc4-kms-v3d
disable_fw_kms_setup=1

# Autoload overlays for any recognized cameras or displays that are attached
# to the CSI/DSI ports. Please note this is for libcamera support, *not* for
# the legacy camera stack
camera_auto_detect=1
display_auto_detect=1

# Config settings specific to arm64
dtoverlay=dwc2

[pi4]
max_framebuffers=2
arm_boost=1

[pi3+]
dtoverlay=vc4-kms-v3d,cma-128

[pi02]
dtoverlay=vc4-kms-v3d,cma-128

[cm4]
dtoverlay=dwc2,dr_mode=host

[all]

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
sed -i 's/BASE = 512/BASE = 437/' gpiod-sysfs-proxy
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