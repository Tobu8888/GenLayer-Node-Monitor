#!/bin/bash

# ============================================================
# GenLayer Node Monitor - Setup Script
# Author: Tobu8888
# ============================================================

set -e

GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
RESET='\033[0m'

echo ""
echo -e "${BOLD}${CYAN}============================================${RESET}"
echo -e "${BOLD}   GenLayer Node Monitor - Setup${RESET}"
echo -e "${BOLD}${CYAN}============================================${RESET}"
echo ""

# ---------- Check Python ----------
echo -e "${CYAN}[1/4] Checking Python...${RESET}"
if ! command -v python3 &>/dev/null; then
    echo -e "${RED}Python3 not found. Please install Python 3.8+${RESET}"
    exit 1
fi
PYTHON_VERSION=$(python3 --version 2>&1)
echo -e "${GREEN}✅ Found: ${PYTHON_VERSION}${RESET}"

# ---------- Install dependencies ----------
echo ""
echo -e "${CYAN}[2/4] Installing Python dependencies...${RESET}"
pip3 install -r requirements.txt --break-system-packages --quiet 2>/dev/null || \
pip3 install -r requirements.txt --quiet 2>/dev/null || \
pip install -r requirements.txt --quiet 2>/dev/null

echo -e "${GREEN}✅ Dependencies installed${RESET}"

# ---------- Make scripts executable ----------
echo ""
echo -e "${CYAN}[3/4] Setting permissions...${RESET}"
chmod +x monitor.sh
echo -e "${GREEN}✅ monitor.sh is now executable${RESET}"

# ---------- Setup .env ----------
echo ""
echo -e "${CYAN}[4/4] Setting up environment config...${RESET}"
if [ ! -f .env ]; then
    cp .env.example .env
    echo -e "${YELLOW}⚠️  Created .env from template. Please edit it:${RESET}"
    echo -e "    ${BOLD}nano .env${RESET}"
else
    echo -e "${GREEN}✅ .env already exists${RESET}"
fi

# ---------- Done ----------
echo ""
echo -e "${BOLD}${GREEN}============================================${RESET}"
echo -e "${BOLD}${GREEN}  Setup complete! 🎉${RESET}"
echo -e "${BOLD}${GREEN}============================================${RESET}"
echo ""
echo -e "Next steps:"
echo -e "  1. Edit your config:  ${BOLD}nano .env${RESET}"
echo -e "  2. Start monitoring:  ${BOLD}./monitor.sh${RESET}"
echo -e "  3. Analyze logs:      ${BOLD}cat node.log | python3 ai_analyzer.py${RESET}"
echo ""
