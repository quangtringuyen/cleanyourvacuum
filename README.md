# Xiaomi Vacuum-Mop P (STYTJ02YM / STYJ02YM) Root, Valetudo & Vietnamese Voice Guide

A turnkey, field-tested toolkit to root the **Xiaomi Mi Robot Vacuum-Mop P / Pro** (`STYTJ02YM` / `STYJ02YM`, Viomi V7/V8), install **Valetudo** (100% cloud-free local web control), and replace all voice prompts with **natural Vietnamese**.

---

## 🌟 Features
1. **100% Local Control (Valetudo)**: Access your robot at `http://<ROBOT_IP>` from any browser (phone, tablet, Mac/PC).
   - Real-time live LiDAR map.
   - Zone cleaning, virtual walls, and no-go zones.
   - Zero dependence on Xiaomi servers (bypasses region locks, no Mainland China server required).
   - Home Assistant / MQTT integration.
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

## 🚀 Quick Start (Automated Scripts)

Clone this repository to your computer:
```bash
git clone git@github.com:quangtringuyen/cleanyourvacuum.git
cd cleanyourvacuum
```

---

### Step 1: Disassemble & Connect Cable
1. **Power off** the vacuum (hold Power button until lights turn off).
2. Remove the 2-in-1 dustbin/water tank.
3. Flip the vacuum upside down on a soft towel.
4. Remove the orange roller brush and brush guard.
5. Unscrew the **4 small screws** on the plastic maintenance plate inside the brush cavity.
6. **Disconnect the internal battery connector** from the motherboard.
7. Plug the Micro-USB cable into the vacuum port (leave the other end unplugged from your Mac for now).

---

### Step 2: Run Root Exploit
Start the automated listener script:
```bash
./scripts/1_root_exploit.sh
```

When prompted:
1. **Press and HOLD the Home (Dock) button** on the vacuum — do not let go.
2. While still holding Home: **Plug the USB cable into your Mac**.
3. While still holding Home: **Rapidly press the Power button 10 times**.
4. **Release both buttons.**

The script will automatically catch the 1-second ADB window, inject `/bin/adb_shell`, and remove the watchdog service.

---

### Step 3: Setup SSH & Wi-Fi
1. **Plug the battery connector back into the motherboard.**
2. Power on the vacuum (or place it on the charging dock).
3. Run:
```bash
./scripts/2_setup_ssh.sh
```
This script will automatically:
- Install Dropbear SSH server.
- Push your computer SSH key to the vacuum.
- Fix Dropbear RSA host key generation.
- Restore robot system services.
- Configure the `ssh vacuum` alias in `~/.ssh/config`.

You can now unplug the USB cable and screw the maintenance plate back on!

---

### Step 4: Install Vietnamese Voice Pack (Optional)
Generate all 139 translated audio prompts:
```bash
python3 generate_vietnamese_voicepack.py
```

Deploy to the vacuum over Wi-Fi:
```bash
./scripts/5_deploy_voicepack.sh
```
*(This automatically copies the audio files to `/mnt/UDISK/audio/vietnamese`, symlinks `mandarin` to `vietnamese`, permanently deletes the old Mandarin files, and plays a test sound).*

---

### Step 5: Install Valetudo (Local Web UI)
Install Valetudo with one command over Wi-Fi:
```bash
./scripts/3_install_valetudo.sh
```
This script will:
- Download and push the verified Valetudo ARMv7 binary.
- Configure the `/etc/init.d/valetudo` autostart service.
- Disable `blockExternalAccess` in Valetudo configuration.
- Override Xiaomi Cloud domains in `/etc/hosts`.
- Reboot the vacuum.

---

## 📱 Accessing Your Vacuum Dashboard

Wait ~45 seconds after reboot, then open your browser on any phone, tablet, or PC connected to your home Wi-Fi:
👉 **`http://<ROBOT_IP>`** (e.g. `http://192.168.1.166`)

Enjoy your private, cloud-free, Vietnamese-speaking smart vacuum!
