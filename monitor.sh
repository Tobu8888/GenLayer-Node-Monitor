#!/bin/bash

# ===== AUTO PATH =====
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

# ===== CONFIG (แก้ได้ผ่าน env) =====
CONFIG_PATH="${CONFIG_PATH:-$HOME/v0.5.8/genlayer-node-linux-amd64/configs/node/config.yaml}"
LOG_FILE="${LOG_FILE:-$BASE_DIR/node.log}"
PROCESS_NAME="${PROCESS_NAME:-genlayer}"

# ===== LOAD NODE INFO =====
if command -v yq &> /dev/null && [ -f "$CONFIG_PATH" ]; then
  NODE_MODE=$(yq '.node.mode' "$CONFIG_PATH" 2>/dev/null)
  NETWORK=$(yq '.node.network' "$CONFIG_PATH" 2>/dev/null)
else
  NODE_MODE="unknown"
  NETWORK="unknown"
fi

# ===== TIME =====
TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")

# ===== LOG ROTATION (1MB) =====
if [ -f "$LOG_FILE" ] && [ $(stat -c%s "$LOG_FILE") -gt 1000000 ]; then
  > "$LOG_FILE"
fi

# ===== CHECK NODE =====
echo "[$TIMESTAMP] 🔍 Checking node ($NODE_MODE | $NETWORK)..." >> "$LOG_FILE"

if pgrep -f "$PROCESS_NAME" > /dev/null
then
  echo "[$TIMESTAMP] ✅ Status: RUNNING ($NODE_MODE | $NETWORK)" >> "$LOG_FILE"
else
  echo "[$TIMESTAMP] ❌ Status: DOWN ($NODE_MODE | $NETWORK) - Restarting..." >> "$LOG_FILE"
  
  # try restart (fallback safe)
  if [ -d "$HOME/v0.5.8/genlayer-node-linux-amd64" ]; then
    cd "$HOME/v0.5.8/genlayer-node-linux-amd64"
    ./genlayer up &
    echo "[$TIMESTAMP] 🚀 Action: Node restarted" >> "$LOG_FILE"
  else
    echo "[$TIMESTAMP] ⚠️ Warning: Node path not found, cannot restart" >> "$LOG_FILE"
  fi
fi

echo "--------------------------------------------------" >> "$LOG_FILE"
