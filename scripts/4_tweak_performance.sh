#!/bin/bash
set -eo pipefail

TARGET="${1:-vacuum}"
echo "=========================================================="
echo "  Applying Efficiency & Cleaning Performance Tweaks"
echo "  Target: $TARGET"
echo "=========================================================="

ssh "$TARGET" << 'REMOTE_EOF'
echo "[*] Creating safety backup of existing configs in /mnt/UDISK/config_backup..."
mkdir -p /mnt/UDISK/config_backup
cp -r /mnt/UDISK/config/*.ini /mnt/UDISK/config_backup/

echo "[*] Boosting main roller brush agitation (65% -> 80%)..."
sed -i 's/roll_brush_ratio=6.500000e+01/roll_brush_ratio=8.000000e+01/' /mnt/UDISK/config/hwdrivers.ini

echo "[*] Disabling heavy background debug logs (saving CPU, RAM & flash writes)..."
sed -i 's/add_to_logfile=1/add_to_logfile=0/' /mnt/UDISK/config/app_log_config.ini
sed -i 's/also_printf=1/also_printf=0/' /mnt/UDISK/config/app_log_config.ini
sed -i 's/log_all=1/log_all=0/' /mnt/UDISK/config/app_log_config.ini
sed -i 's/log_all=1/log_all=0/' /mnt/UDISK/config/log_config.ini

echo "[*] Disabling headless 3D scene rendering in ICP mapping engine..."
for f in /mnt/UDISK/config/*icp-params.ini; do
  sed -i 's/SAVE_3D_SCENE=1/SAVE_3D_SCENE=0/' "$f"
  sed -i 's/SHOW_PROGRESS_3D_REAL_TIME=1/SHOW_PROGRESS_3D_REAL_TIME=0/' "$f"
  sed -i 's/SHOW_LASER_SCANS_3D=1/SHOW_LASER_SCANS_3D=0/' "$f"
done

echo "[*] Purging accumulated old log dumps..."
rm -f /mnt/UDISK/log/scheme_data.info1* /mnt/UDISK/log/wifimanager.temp

echo ">>> All tweaks successfully applied!"
REMOTE_EOF

echo ""
echo "=========================================================="
echo "  TWEAKS APPLIED SUCCESSFULLY!"
echo "=========================================================="
echo " - Roller brush agitation boosted to 80% (deeper carpet/grout clean)"
echo " - Verbose developer logging disabled (CPU stays cool & fast)"
echo " - 3D scene visualization disabled in SLAM engine"
echo " - Old log debris purged"
echo "=========================================================="
