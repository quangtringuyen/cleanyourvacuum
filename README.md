# Xiaomi Vacuum-Mop P (STYTJ02YM / STYJ02YM) Root, Valetudo & Vietnamese Voice Guide

A complete, field-tested guide to rooting the **Xiaomi Mi Robot Vacuum-Mop P / Pro** (model `STYTJ02YM` / `STYJ02YM`, Viomi V7/V8), installing **Valetudo** (100% cloud-free local web control), and replacing the voice pack with **natural Vietnamese**.

---

## 🌟 What You Get
1. **100% Local Control (Valetudo)**: Access your robot at `http://<ROBOT_IP>` from any browser (phone, tablet, Mac/PC).
   - Real-time live LiDAR map.
   - Zone cleaning, virtual walls, and no-go zones.
   - Zero dependence on Xiaomi servers (no region lock, no Mainland China server requirement).
   - Home Assistant / MQTT plug-and-play integration.
2. **Natural Vietnamese Voice Pack**: 139 translated prompts covering every action and alert.
3. **Mandarin Removed**: Clean storage and no unwanted Chinese voice prompts.
4. **Permanent SSH Access**: Manage your vacuum wirelessly anytime over Wi-Fi (`ssh vacuum`).

---

## 🛠️ Requirements & Tools
- **Robot:** Xiaomi Mi Robot Vacuum-Mop P (`STYTJ02YM` or `STYJ02YM`).
- **Cable:** A high-quality **Micro-USB to USB-A (or USB-C)** data cable.
- **Tools:** A small Phillips screwdriver (`#0` or `#1`).
- **Computer:** macOS or Linux machine connected to the same Wi-Fi as the robot.
- **Prerequisites on Mac:**
  ```bash
  brew install android-platform-tools coreutils wget
  python3 -m pip install gTTS
  ```

---

## 🔌 Phase 1: Hardware Access & Cable Setup

1. **Power off** the vacuum completely (hold Power button until lights go off).
2. Remove the 2-in-1 dustbin/water tank.
3. Flip the robot upside down onto a soft towel (to protect the LiDAR sensor).
4. Remove the orange roller brush and brush guard.
5. Unscrew the **4 small screws** holding the plastic maintenance plate inside the brush cavity.
6. **Disconnect the internal battery connector** from the motherboard (important for boot exploit timing).
7. Locate the **Micro-USB port** soldered near the edge of the board inside the compartment.
8. Plug the Micro-USB cable into the vacuum (leave the other end unplugged from your Mac for now).

---

## ⚡ Phase 2: The Bootloader Exploit (Entering Developer Mode)

On the `STYTJ02YM` (Viomi V8), the board exposes a brief 1-second ADB window on boot.

### 1. Start the exploit listener on your Mac:
Run this listener loop in Terminal before plugging the cable into your Mac:
```bash
cat > adb_shell <<"SHELL_EOF"
#!/bin/sh
export ENV="/etc/adb_profile"
exec /bin/sh "$@"
SHELL_EOF
chmod +x adb_shell

echo "Waiting for ADB connection..."
while true; do
  out=$(adb push -a adb_shell /bin/adb_shell 2>&1)
  if ! echo "$out" | grep -q "no devices/emulators found"; then
    echo ">>> Caught ADB: $out"
    break
  fi
  sleep 0.05
done

while true; do
  out=$(adb shell rm /etc/rc.d/S90robotManager 2>&1)
  if ! echo "$out" | grep -q "no devices/emulators found"; then
    echo ">>> Watchdog removed: $out"
    break
  fi
  sleep 0.05
done
echo ">>> SUCCESS: ADB Shell is persistent! <<<"
```

### 2. Perform the Button Sequence on the Vacuum:
1. Ensure the battery is **unplugged**.
2. **Press and HOLD the Home (Dock) button** — do not let go.
3. While still holding Home, **plug the USB cable into your Mac**.
4. While still holding Home, **press the Power button 10 times** in rapid succession.
5. **Release both buttons.**

The Mac script will immediately catch the ADB bridge, push `/bin/adb_shell`, and remove the watchdog service.

---

## 🔑 Phase 3: Setup Permanent SSH

1. **Plug the battery connector back into the motherboard.**
2. Leave the USB cable plugged into your Mac and power the vacuum on.
3. When `adb devices` shows the robot, install Dropbear SSH:
```bash
# Download Dropbear IPK
wget https://itooktheredpill.irgendwo.org/static/2020/dropbear_2015.71-2_sunxi.ipk -O dropbear.ipk
adb push dropbear.ipk /tmp/
adb shell opkg install /tmp/dropbear.ipk

# Push your Mac SSH public key
adb shell mkdir -p /etc/dropbear
adb push ~/.ssh/id_rsa.pub /etc/dropbear/authorized_keys
adb shell chmod 0600 /etc/dropbear/authorized_keys

# Fix Dropbear empty host key bug (critical!)
adb shell "rm -f /etc/dropbear/dropbear_*_host_key && dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key"

# Enable and start Dropbear
adb shell /etc/init.d/dropbear enable
adb shell /usr/sbin/dropbear -p 22

# Restore robot services
adb shell "cd /etc/rc.d && ln -sf ../init.d/robotManager S90robotManager"
```

4. Find the robot Wi-Fi IP address:
```bash
adb shell ifconfig wlan0 | grep "inet addr"
```
*(Example IP: `192.168.1.166`)*

5. Add an SSH alias to your Mac (`~/.ssh/config`):
```text
Host vacuum
  Hostname 192.168.1.166
  User root
  PubkeyAcceptedKeyTypes +ssh-rsa
  HostkeyAlgorithms +ssh-rsa
  StrictHostKeyChecking no
```

Now you can unplug the USB cable, reassemble the 4 screws, and test logging in wirelessly:
```bash
ssh vacuum
```

---

## 🇻🇳 Phase 4: Install Vietnamese Voice Pack & Remove Mandarin

1. **Generate the 139 Vietnamese Audio Prompts:**
   Run the provided Python script:
   ```bash
   python3 generate_vietnamese_voicepack.py
   ```
2. **Upload to the Robot via Wi-Fi:**
   ```bash
   ssh vacuum "mkdir -p /mnt/UDISK/audio/vietnamese"
   tar -czf - -C vietnamese_voicepack . | ssh vacuum "tar -xzf - -C /mnt/UDISK/audio/vietnamese"
   ```
3. **Activate Vietnamese & Remove Mandarin:**
   ```bash
   # Point mandarin folder to the new Vietnamese pack
   ssh vacuum "ln -sfn /mnt/UDISK/audio/vietnamese /usr/share/audio/mandarin"

   # Remove original Mandarin audio to save storage
   ssh vacuum "rm -rf /usr/share/audio/mandarin_orig"

   # Test voice playback
   ssh vacuum "tinyplayer /usr/share/audio/mandarin/7sound_global_clean_start.mp3"
   ```

---

## 🌐 Phase 5: Install Valetudo (Local Web UI)

1. **Download Valetudo for ARMv7 on your Mac:**
   ```bash
   wget https://github.com/Hypfer/Valetudo/releases/download/2022.05.1/valetudo-armv7 -O valetudo
   ```
2. **Push to Robot Storage (`/mnt/UDISK`):**
   ```bash
   ssh vacuum "cat > /mnt/UDISK/valetudo; chmod 755 /mnt/UDISK/valetudo" < valetudo
   ```
3. **Create the Init Service (`/etc/init.d/valetudo`):**
   ```bash
   ssh vacuum "cat > /etc/init.d/valetudo" << "EOF"
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
EOF
   ssh vacuum "chmod +x /etc/init.d/valetudo && cd /etc/rc.d && ln -sf ../init.d/valetudo S97valetudo"
   ```
4. **Block Xiaomi Cloud & Redirect Endpoints:**
   ```bash
   ssh vacuum << "EOF"
for domain in "" de. ea. in. pv. ru. sg. st. tw. us.; do
  grep -q "${domain}ot.io.mi.com" /etc/hosts || echo "127.0.0.1 ${domain}ot.io.mi.com ${domain}ott.io.mi.com" >> /etc/hosts
done
sed -i "s/110.43.0.8./127.00.00.1/g" /usr/bin/miio_client 2>/dev/null || true
EOF
   ```
5. **Reboot the Vacuum:**
   ```bash
   ssh vacuum "reboot"
   ```

---

## 📱 Accessing Your Vacuum Dashboard

Once the vacuum boots back up, open your web browser on any device connected to your home Wi-Fi:
👉 **`http://<ROBOT_IP>`** (e.g. `http://192.168.1.166`)

Enjoy your cloud-free, Vietnamese-speaking smart vacuum!
