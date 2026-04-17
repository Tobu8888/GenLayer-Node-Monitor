#!/bin/bash

# ============================================================
# GenLayer Node Monitor + Auto-Recovery
# Author: Tobu8888
# Description: Monitors GenLayer full/validator node health,
#              auto-restarts on failure, and logs events.
# ============================================================

# ---------- CONFIG ----------
NODE_DIR="${HOME}/v0.5.8/genlayer-node-linux-amd64"
CONFIG_FILE="${NODE_DIR}/configs/node/config.yaml"
NODE_BIN="${NODE_DIR}/bin/genlayernode"
NODE_PASSWORD="${GENLAYER_PASSWORD:-12345678}"   # set via env var
LOG_FILE="$(dirname "$0")/node.log"
HEALTH_URL="http://localhost:9153/health"
RPC_URL="http://localhost:9151"
CHECK_INTERVAL=60   # seconds between checks
MAX_RESTART_ATTEMPTS=5
RESTART_COOLDOWN=30  # seconds to wait before restarting

# ---------- COLORS ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

# ---------- STATE ----------
restart_count=0
total_checks=0
downtime_events=0
start_time=$(date +%s)

# ---------- FUNCTIONS ----------

log() {
    local level="$1"
    local msg="$2"
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    echo "${timestamp} [${level}] ${msg}" | tee -a "$LOG_FILE"
}

detect_node_mode() {
    if grep -q 'mode: "validator"' "$CONFIG_FILE" 2>/dev/null; then
        echo "validator"
    else
        echo "full"
    fi
}

detect_network() {
    grep -oP 'network=\K[^\s]+' "$LOG_FILE" 2>/dev/null | tail -1 || echo "unknown"
}

is_node_running() {
    pgrep -f "genlayernode run" > /dev/null 2>&1
}

check_health_endpoint() {
    local response
    response=$(curl -sf --max-time 5 "$HEALTH_URL" 2>/dev/null)
    if [ $? -eq 0 ]; then
        echo "ok"
    else
        echo "fail"
    fi
}

check_rpc_sync() {
    local response
    response=$(curl -sf --max-time 5 -X POST "$RPC_URL" \
        -H "Content-Type: application/json" \
        -d '{"jsonrpc":"2.0","method":"gen_syncing","params":[],"id":1}' 2>/dev/null)
    echo "$response"
}

get_latest_block() {
    local response
    response=$(curl -sf --max-time 5 -X POST "$RPC_URL" \
        -H "Content-Type: application/json" \
        -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' 2>/dev/null)
    local hex_block
    hex_block=$(echo "$response" | grep -oP '"result":"\K[^"]+' 2>/dev/null)
    if [ -n "$hex_block" ]; then
        printf "%d" "$hex_block" 2>/dev/null || echo "unknown"
    else
        echo "unknown"
    fi
}

start_node() {
    if [ $restart_count -ge $MAX_RESTART_ATTEMPTS ]; then
        log "ERROR" "Max restart attempts ($MAX_RESTART_ATTEMPTS) reached. Manual intervention required."
        return 1
    fi

    log "INFO" "Starting GenLayer node... (attempt $((restart_count + 1))/${MAX_RESTART_ATTEMPTS})"

    cd "$NODE_DIR" || { log "ERROR" "Cannot cd to $NODE_DIR"; return 1; }

    nohup "$NODE_BIN" run \
        -c "$CONFIG_FILE" \
        --password "$NODE_PASSWORD" \
        >> "$LOG_FILE" 2>&1 &

    sleep 5

    if is_node_running; then
        restart_count=$((restart_count + 1))
        log "INFO" "Node started successfully (PID: $(pgrep -f 'genlayernode run'))"
        return 0
    else
        log "ERROR" "Node failed to start."
        return 1
    fi
}

print_status_banner() {
    local mode
    mode=$(detect_node_mode)
    local network
    network=$(detect_network)
    local uptime_seconds=$(( $(date +%s) - start_time ))
    local uptime_human
    uptime_human=$(printf '%02dh:%02dm:%02ds' $((uptime_seconds/3600)) $((uptime_seconds%3600/60)) $((uptime_seconds%60)))
    local block
    block=$(get_latest_block)
    local health
    health=$(check_health_endpoint)

    echo ""
    echo -e "${BOLD}${CYAN}============================================${RESET}"
    echo -e "${BOLD}     GenLayer Node Monitor Status${RESET}"
    echo -e "${BOLD}${CYAN}============================================${RESET}"
    echo -e " Mode       : ${BOLD}${mode}${RESET}"
    echo -e " Network    : ${BOLD}${network}${RESET}"
    echo -e " Operator   : ${BOLD}0x74D7467E3C0220F86bA75Aec21F4A3c3A8d6e74b${RESET}"
    echo -e " Monitor Up : ${BOLD}${uptime_human}${RESET}"
    echo -e " Checks     : ${BOLD}${total_checks}${RESET}"
    echo -e " Restarts   : ${BOLD}${restart_count}${RESET}"
    echo -e " Downtime   : ${BOLD}${downtime_events} event(s)${RESET}"
    echo -e " Block      : ${BOLD}${block}${RESET}"
    if [ "$health" = "ok" ]; then
        echo -e " Health     : ${GREEN}${BOLD}✅ OK${RESET}"
    else
        echo -e " Health     : ${RED}${BOLD}❌ FAIL${RESET}"
    fi
    echo -e "${BOLD}${CYAN}============================================${RESET}"
    echo ""
}

# ---------- MAIN LOOP ----------

log "INFO" "=========================================="
log "INFO" "  GenLayer Node Monitor Started"
log "INFO" "  Mode    : $(detect_node_mode)"
log "INFO" "  Config  : $CONFIG_FILE"
log "INFO" "  Log     : $LOG_FILE"
log "INFO" "=========================================="

# Start node if not already running
if ! is_node_running; then
    log "WARN" "Node is not running. Starting..."
    start_node
fi

while true; do
    total_checks=$((total_checks + 1))

    if is_node_running; then
        health=$(check_health_endpoint)
        if [ "$health" = "ok" ]; then
            log "INFO" "Node healthy. Block=$(get_latest_block) Checks=${total_checks} Restarts=${restart_count}"
        else
            log "WARN" "Node running but health endpoint not responding."
        fi
    else
        log "ERROR" "Node is DOWN! Attempting restart..."
        downtime_events=$((downtime_events + 1))
        sleep "$RESTART_COOLDOWN"
        start_node
    fi

    # Print status every 10 checks
    if (( total_checks % 10 == 0 )); then
        print_status_banner
    fi

    sleep "$CHECK_INTERVAL"
done
