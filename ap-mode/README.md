# rpi4-AP-mode

dnsmasq: 소규머 네트워크 서버 구성
hostapd: 무선 엑세스 포인트를 관리 (특히, 하나의 무선 카드로 여러 SSID를 브로드캐스트하는 기능 제공)

```bash
sudo apt update
sudo apt install dnsmasq hostapd
```

- `/etc/hostapd/hostapd.conf` 작성 (주의: 암호는 8자 이상)
```bash
sudo tee /etc/hostapd/hostapd.conf > /dev/null <<'EOF'
interface=ap0
ssid=my_ssid_name
hw_mode=g
channe1=6
ieee80211n=1
wmm_enabled=1
macaddr_ac1=0
auth_algs=1
ignore_broadcast_ssid=0
wpa=2
wpa_key_mgmt=WPA-PSK
wpa_passphrase=my_password
rsn_pairwise=CCMP
EOF
```


- `/etc/default/hostapd` 작성
```
DAEMON_CONF="/etc/hostapd/hostapd.conf"
```

- hostapd 재실행
```bash
sudo systemctl unmask hostapd
sudo systemctl enable hostapd
```

- `/etc/dnsmasq.conf` 수정
```
port=5353
interface=ap0
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
```


- dnsmasq 재시작
```bash
sudo systemctl restart dnsmasq
```

- `/etc/sysctl.conf`에서 ipv4 부분 한줄 주석 해제

```
net.ipv4.ip_forward=1
```

- iw 설치 (wifi 인터페이스를 설정하고 관리하는 도구)
```bash
sudo apt update
sudo apt install iw
```

- 가상네트워크 생성 (나중에 이걸 system.service에 등록할 거임)
```bash
sudo iw dev wlan0 interface add ap0 type __ap
sudo ifconfig ap0 192.168.4.1/24 netmask 255.255.255.0

sudo ifconfig ap0 up
```

- 잘 뜨는지 확인
```bash
ifconfig
```

- 서비스로 등록
```bash
sudo tee /etc/systemd/pw-ap-mode.service > /dev/null <<'EOF'
[Unit]
Description=Minibot AP Network Setup
After=network.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c "/usr/bin/sudo /sbin/iw dev wlan0 interface add ap0 type __ap && \
    /bin/sleep 3 && \
    /usr/bin/sudo /sbin/ifconfig ap0 192.168.4.1/24 netmask 255.255.255.0 && \
    /usr/bin/sudo /sbin/ifconfig ap0 up && \
    /usr/bin/sudo /sbin/iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE"
RemainAfterExit=true

[Install]
WantedBy=multi-user.target
EOF
```

- 대몬 리로드
```bash
sudo systemctl daemon-reload
sudo systemctl enable pw-ap-mode.service
```

ip 주소는 이제 `192.168.4.1`로 설정됨

----------------------------
- 인터넷 잡기
```bash
sudo tee ~/wifi_setup.sh > /dev/null <<'EOF'
#!/bin/bash
read -p "Enter WiFi SSID: " wifi_ssid
read -p "Enter WiFi Password: " wifi_password
echo
if [ -z "$wifi_password" ]; then
    sudo nmcli device wifi connect "$wifi_ssid" ifname wlan0
else
    sudo nmcli device wifi connect "$wifi_ssid" password "$wifi_password" ifname wlan0
fi
if [ $? -eq 0 ]; then
    echo "Successfully connected to $wifi_ssid"
else
    echo "Failed to connect to $wifi_ssid"
fi
EOF

sudo chmod 777 ~/wifi_setup.sh
```


- 가능한 wifi목록 보기
```bash
nmcli dev wifi list
```