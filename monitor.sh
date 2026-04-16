#!/bin/bash

# ===== AUTO PATH =====
BASE_DIR="$(cd "$(dirname "$0")" && pwd)"

# ===== CONFIG =====
CONFIG_PATH="${CONFIG_PATH:-$HOME/v0.5.8/genlayer-node-linux-amd64/configs/node/config.yaml}"
LOG_FILE="${LOG_FILE:-$BASE_DIR/node.log}"
PROCESS_NAME="${PROCESS_NAME:-genlayer}"
NODE_DIR="${NODE_DIR:-$HOME/v0.5.8/genlayer-node-linux-amd64}"

MAX_RETRIES=3
RETRY_DELAY=3

LOCK_FILE="/tmp/genlayer-monitor.lock"

# ===== LOCK (prevent duplicate runs) =====
if [ -f "$LOCK_FILE" ]; then
  echo "[WARN] Script already running, exiting..."
  exit 1
fi

trap "rm -f $LOCK_FILE" EXIT
touch "$LOCK_FILE"

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

# ===== LOG ROTATION =====
if [ -f "$LOG_FILE" ] && [ $(stat -c%s "$LOG_FILE") -gt 1000000 ]; then
  > "$LOG_FILE"
fi

# ===== CHECK NODE =====
echo "[$TIMESTAMP] 🔍 Checking node ($NODE_MODE | $NETWORK)..." >> "$LOG_FILE"

if pgrep -f "$PROCESS_NAME" > /dev/null
then
  UPTIME=$(uptime -p)
  echo "[$TIMESTAMP] ✅ Status: RUNNING ($NODE_MODE | $NETWORK)" >> "$LOG_FILE"
  echo "[$TIMESTAMP] ⏱ Uptime: $UPTIME" >> "$LOG_FILE"
else
  echo "[$TIMESTAMP] ❌ Status: DOWN ($NODE_MODE | $NETWORK)" >> "$LOG_FILE"
  echo "[$TIMESTAMP] 🔁 Attempting restart..." >> "$LOG_FILE"

  # ===== SAFE RESTART =====
  pkill -f "$PROCESS_NAME" 2>/dev/null

  RETRY_COUNT=0
  SUCCESS=false

  while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    ((RETRY_COUNT++))

    echo "[$TIMESTAMP] 🔄 Retry $RETRY_COUNT/$MAX_RETRIES..." >> "$LOG_FILE"

    if [ -d "$NODE_DIR" ]; then
      cd "$NODE_DIR"
      ./genlayer up &
      sleep 5
    else
      echo "[$TIMESTAMP] ⚠️ Node directory not found!" >> "$LOG_FILE"
      break
    fi

    if pgrep -f "$PROCESS_NAME" > /dev/null; then
      SUCCESS=true
      break
    fi

    sleep $RETRY_DELAY
  done

  # ===== RESULT =====
  if [ "$SUCCESS" = true ]; then
    echo "[$TIMESTAMP] 🚀 Restart successful after $RETRY_COUNT attempt(s)" >> "$LOG_FILE"
  else
    echo "[$TIMESTAMP] ❌ Restart failed after $MAX_RETRIES attempts" >> "$LOG_FILE"
  fi
fi

echo "--------------------------------------------------" >> "$LOG_FILE"
