#!/bin/bash
set -eo pipefail

TARGET="${1:-vacuum}"
VOICE_DIR="${2:-vietnamese_voicepack}"

if [ ! -d "$VOICE_DIR" ]; then
  echo "[-] Directory $VOICE_DIR does not exist. Run generate_vietnamese_voicepack.py first!"
  exit 1
fi

COUNT=$(ls -1 "$VOICE_DIR" | wc -l | tr -d ' ')
echo "=========================================================="
echo "  Deploying $COUNT Vietnamese Audio Prompts to $TARGET"
echo "=========================================================="

echo "[*] Creating remote directory /mnt/UDISK/audio/vietnamese..."
ssh "$TARGET" "mkdir -p /mnt/UDISK/audio/vietnamese"

echo "[*] Streaming audio files over SSH..."
tar -czf - -C "$VOICE_DIR" . | ssh "$TARGET" "tar -xzf - -C /mnt/UDISK/audio/vietnamese"

echo "[*] Symlinking mandarin -> vietnamese..."
ssh "$TARGET" "ln -sfn /mnt/UDISK/audio/vietnamese /usr/share/audio/mandarin"

echo "[*] Removing original Mandarin audio files to save space..."
ssh "$TARGET" "rm -rf /usr/share/audio/mandarin_orig"

echo "[*] Testing audio on robot speaker..."
ssh "$TARGET" "tinyplayer /usr/share/audio/mandarin/7sound_global_clean_start.mp3"

echo ""
echo "=========================================================="
echo "  VIETNAMESE VOICE PACK ACTIVATED SUCCESSFULLY!"
echo "=========================================================="
