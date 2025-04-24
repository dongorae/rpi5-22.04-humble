sudo apt update

sudo apt install dnsmasq hostapd

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


