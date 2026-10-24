#!/bin/bash
set -eo pipefail

TARGET="${1:-vacuum}"
echo "=========================================================="
echo "  Installing Valetudo on $TARGET (Cloud-Free Local UI)"
echo "=========================================================="

VALETUDO_BIN="/tmp/valetudo-armv7"
if [ ! -f "$VALETUDO_BIN" ]; then
  echo "[*] Downloading Valetudo binary for ARMv7..."
  wget -q "https://github.com/Hypfer/Valetudo/releases/download/2022.05.1/valetudo-armv7" -O "$VALETUDO_BIN"
fi

echo "[*] Uploading Valetudo to /mnt/UDISK/valetudo over SSH..."
ssh "$TARGET" "cat > /mnt/UDISK/valetudo && chmod 755 /mnt/UDISK/valetudo" < "$VALETUDO_BIN"

echo "[*] Creating init service (/etc/init.d/valetudo)..."
ssh "$TARGET" "cat > /etc/init.d/valetudo" << 'SERVICE_EOF'
#!/bin/sh /etc/rc.common
START=97
STOP=99

USE_PROCD=1
PROG=/mnt/UDISK/valetudo
OOM_ADJ=-17

start_service() {
  procd_open_instance
  procd_set_param env VALETUDO_CONFIG_PATH=/mnt/UDISK/valetudo_config.json
  procd_set_param oom_adj $OOM_ADJ
  procd_set_param command $PROG
  procd_set_param stdout 1
  procd_set_param stderr 1
  procd_close_instance
}

shutdown() {
  echo shutdown
}
SERVICE_EOF

ssh "$TARGET" "chmod +x /etc/init.d/valetudo && cd /etc/rc.d && ln -sf ../init.d/valetudo S97valetudo"

echo "[*] Overriding Xiaomi Cloud endpoints in /etc/hosts..."
ssh "$TARGET" << 'HOSTS_EOF'
for domain in "" de. ea. in. pv. ru. sg. st. tw. us.; do
  grep -q "${domain}ot.io.mi.com" /etc/hosts || echo "127.0.0.1 ${domain}ot.io.mi.com ${domain}ott.io.mi.com" >> /etc/hosts
done
sed -i 's/110.43.0.8./127.00.00.1/g' /usr/bin/miio_client 2>/dev/null || true
HOSTS_EOF

echo "[*] Ensuring blockExternalAccess is disabled..."
ssh "$TARGET" "test -f /mnt/UDISK/valetudo_config.json && sed -i 's/\"blockExternalAccess\": true/\"blockExternalAccess\": false/' /mnt/UDISK/valetudo_config.json || true"

IP=$(ssh -G "$TARGET" 2>/dev/null | awk '$1 == "hostname" { print $2 }' || true)

echo "[*] Rebooting vacuum to start Valetudo cleanly..."
ssh "$TARGET" "reboot" || true

echo ""
echo "=========================================================="
echo "  VALETUDO INSTALLED SUCCESSFULLY!"
echo "=========================================================="
echo "Wait ~45 seconds for the vacuum to boot up, then open:"
echo "👉 http://${IP:-<ROBOT_IP>}"
echo "=========================================================="
