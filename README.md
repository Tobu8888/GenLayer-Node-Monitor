# GenLayer Node Monitor

A lightweight and portable monitoring tool for GenLayer nodes.  
This script ensures node uptime by automatically detecting failures and restarting the node when necessary.

---

## 🚀 Features

- 🔍 Monitors GenLayer node process
- 🔄 Auto-restarts node if it goes down
- 🧠 Dynamically reads node configuration (mode & network)
- 📝 Clean and structured logging
- 📦 Portable (no hardcoded paths)
- ⚙️ Configurable via environment variables
- 🧹 Log rotation (prevents large log files)

---

## 📦 Requirements

- Linux (Ubuntu / Arch recommended)
- Bash
- Optional: `yq` (for parsing config.yaml)

Install `yq`:

```bash
# Ubuntu
sudo apt install yq

# Arch Linux
sudo pacman -S yq
