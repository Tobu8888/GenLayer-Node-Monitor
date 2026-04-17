# GenLayer Node Monitor + AI Analyzer 🚀

A lightweight monitoring and auto-recovery tool for GenLayer nodes, enhanced with AI-powered log analysis using Claude (Anthropic).

This project ensures node uptime, detects failures, and introduces intelligent decision-making aligned with GenLayer's AI-powered blockchain vision.

---

## ✨ Features

- 🔍 **Node health monitoring** — checks `/health` endpoint and RPC sync status
- 🔁 **Automatic restart** on failure with configurable max attempts
- 📊 **Clean logging** with timestamps and log rotation
- ⚙️ **Dynamic config detection** — auto-detects node mode (full/validator) and network
- 🧠 **AI-powered log analysis** — uses Claude API to analyze stability and generate recommendations
- 📈 **Uptime and stability metrics** — tracks restarts, downtime events, block progress
- 💡 **Smart recommendations** based on actual node behavior
- 🔄 **Fallback rule-based analysis** when API is unavailable

---

## 🧠 AI-Powered Analysis

This project uses the **Anthropic Claude API** to intelligently evaluate node logs and provide insights.

Instead of blindly restarting nodes, the system analyzes historical behavior and generates:

- Stability status: **Stable / Minor Instability / Unstable**
- Uptime ratio and block progress
- Detected issues (LLM failures, Docker errors, sync problems)
- Actionable recommendations specific to your node's behavior

If no API key is available, the system automatically falls back to rule-based analysis.

---

## 📊 Example Output

```text
==================================================
🧠 GenLayer Node AI Analysis Report
==================================================
Time     : 2026-04-16 19:53:11 UTC
Network  : asimov-phase5
Mode     : full
Operator : 0x74D7467E3C022...
Source   : Claude AI (Anthropic)

📊 Metrics:
  - Total log lines   : 1,240
  - INFO events       : 1,180
  - WARNING events    : 55
  - ERROR events      : 5
  - LLM failures      : 3
  - Docker errors     : 2
  - Restart events    : 1
  - Uptime ratio      : 96.00%
  - Latest block      : 325,368

📈 Status:
  ⚠️ Minor Instability

🔍 Key Issues:
  • LLM module failed 3 times — API key may be missing or expired
  • Docker permission errors — user not in docker group

💡 Recommendations:
  → Set HEURISTKEY or OPENAIKEY environment variable before running node
  → Run: sudo usermod -aG docker $USER then re-login
  → Monitor closely over next 24h for recurrence
==================================================
```

---

## ⚙️ Setup

**Clone the repository:**
```bash
git clone https://github.com/Tobu8888/GenLayer-Node-Monitor.git
cd GenLayer-Node-Monitor
```

**Run one-click setup:**
```bash
chmod +x setup.sh
./setup.sh
```

**Edit your config:**
```bash
nano .env
```

---

## ▶️ Usage

**Run node monitor:**
```bash
./monitor.sh
```

**Check logs:**
```bash
cat node.log
```

---

## 🧪 Run AI Analysis

**Analyze logs:**
```bash
python3 ai_analyzer.py
```

**Pipe from node log:**
```bash
cat node.log | python3 ai_analyzer.py
```

**Save AI output:**
```bash
cat node.log | python3 ai_analyzer.py >> ai.log
```

---

## ⏱ Automation (Cron)

Run every 5 minutes:
```bash
crontab -e
```

Add:
```bash
*/5 * * * * /path/to/GenLayer-Node-Monitor/monitor.sh
```

---

## 📁 Project Structure

```
.
├── monitor.sh          # Node monitoring + auto-restart
├── ai_analyzer.py      # AI-powered log analysis (Claude API)
├── setup.sh            # One-click setup script
├── requirements.txt    # Python dependencies
├── .env.example        # Environment variable template
├── node.log            # Node monitor logs (auto-generated)
├── ai.log              # AI analysis output (auto-generated)
└── README.md
```

---

## 🌐 Use Case

- Node operators who want better uptime and visibility
- Developers exploring AI + blockchain infrastructure integration
- Testing node reliability on GenLayer Asimov/Bradbury Testnet

---

## 🧩 Alignment with GenLayer

This project demonstrates a practical step toward **AI-assisted decision-making in blockchain infrastructure**.

By combining real-time monitoring with Claude AI analysis, it showcases how intelligent systems can:
- Detect subtle node instability patterns
- Provide context-aware recommendations
- Reduce manual intervention for node operators
- Contribute to more reliable decentralized networks

---

## 🚀 Future Improvements

- 🤖 Real-time LLM inference using GenLayer Intelligent Contracts
- 📊 Web dashboard (Vercel / Grafana)
- 🔔 Alert system (Telegram / Discord webhook)
- 📈 Node scoring system for validator performance
- 🌐 Multi-node monitoring support

---

## 📄 License

MIT
