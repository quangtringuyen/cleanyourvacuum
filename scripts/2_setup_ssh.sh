#!/bin/bash
set -eo pipefail

echo "=========================================================="
echo "  Setting up Dropbear SSH on Xiaomi Vacuum-Mop P"
echo "=========================================================="

# Ensure local SSH key exists
if [ ! -f "$HOME/.ssh/id_rsa.pub" ] && [ ! -f "$HOME/.ssh/id_ed25519.pub" ]; then
  echo "[*] Generating local SSH keypair..."
  ssh-keygen -t rsa -b 2048 -f "$HOME/.ssh/id_rsa" -N ""
fi

PUB_KEY="$HOME/.ssh/id_rsa.pub"
[ -f "$PUB_KEY" ] || PUB_KEY="$HOME/.ssh/id_ed25519.pub"

echo "[*] Waiting for ADB device..."
while true; do
  res=$(adb shell echo ready 2>/dev/null | tr -d '\r' || true)
  if [ "$res" = "ready" ]; then
    echo ">>> [SUCCESS] ADB device responding!"
    break
  fi
  sleep 0.5
done

# Download Dropbear IPK if not cached
PKG="/tmp/dropbear_2015.71-2_sunxi.ipk"
if [ ! -f "$PKG" ]; then
  echo "[*] Downloading Dropbear package..."
  wget -q "https://itooktheredpill.irgendwo.org/static/2020/dropbear_2015.71-2_sunxi.ipk" -O "$PKG"
fi

echo "[*] Installing Dropbear on robot..."
adb push "$PKG" /tmp/dropbear.ipk
adb shell opkg install /tmp/dropbear.ipk

echo "[*] Configuring SSH authorized_keys..."
adb shell mkdir -p /etc/dropbear
adb push "$PUB_KEY" /etc/dropbear/authorized_keys
adb shell chmod 0600 /etc/dropbear/authorized_keys

echo "[*] Generating clean RSA host key (fixes empty host key bug)..."
adb shell "rm -f /etc/dropbear/dropbear_*_host_key && dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key"

echo "[*] Enabling Dropbear service and starting on port 22..."
adb shell /etc/init.d/dropbear enable
adb shell /usr/sbin/dropbear -p 22

echo "[*] Restoring robot services..."
adb shell "cd /etc/rc.d && ln -sf ../init.d/robotManager S90robotManager"

echo "[*] Ensuring Dropbear autostarts in /etc/rc.local..."
adb shell "grep -q dropbear /etc/rc.local || sed -i '/exit 0/i pgrep dropbear || /usr/sbin/dropbear -p 22' /etc/rc.local"

# Determine robot IP
IP=$(adb shell ifconfig wlan0 2>/dev/null | awk '/inet addr/{print substr($2,6)}' | tr -d '\r')
echo ""
echo "=========================================================="
if [ -n "$IP" ]; then
  echo "Robot Wi-Fi IP Address: $IP"
  mkdir -p "$HOME/.ssh"
  if ! grep -q "Host vacuum" "$HOME/.ssh/config" 2>/dev/null; then
    cat >> "$HOME/.ssh/config" <<SSH_EOF

Host vacuum
  Hostname $IP
  User root
  PubkeyAcceptedKeyTypes +ssh-rsa
  HostkeyAlgorithms +ssh-rsa
  StrictHostKeyChecking no
SSH_EOF
    echo "Added 'vacuum' alias to ~/.ssh/config."
  fi
  echo "You can now connect wirelessly from your terminal:"
  echo "  ssh vacuum"
else
  echo "Robot is not connected to Wi-Fi yet. Connect via ADB to check."
fi
echo "=========================================================="
echo "You may now safely unplug the USB cable and assemble the vacuum!"
