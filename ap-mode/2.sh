sudo tee -a /etc/default/hostapd > /dev/null <<'EOF'
DAEMON_CONF="/etc/hostapd/hostapd.conf"
EOF

sudo systemctl unmask hostapd
sudo systemctl enable hostapd

sudo tee -a /etc/dnsmasq.conf > /dev/null <<'EOF'
port=5353
interface=ap0
dhcp-range=192.168.4.2,192.168.4.20,255.255.255.0,24h
EOF

sudo systemctl restart dnsmasq

sudo tee -a /etc/sysctl.conf > /dev/null <<'EOF'
net.ipv4.ip_forward=1
EOF

sudo apt update
sudo apt install iw

# sudo iw dev wlan0 interface add ap0 type __ap
# sudo ifconfig ap0 192.168.4.1/24 netmask 255.255.255.0

# sudo ifconfig ap0 up

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

sudo systemctl daemon-reload
sudo systemctl enable pw-ap-mode.service