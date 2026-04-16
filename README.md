## GenLayer Node Monitor + AI Analyzer 🚀

A lightweight monitoring and auto-recovery tool for GenLayer nodes, enhanced with AI-inspired log analysis.

This project ensures node uptime, detects failures, and introduces intelligent decision-making concepts aligned with GenLayer’s AI-powered blockchain vision.

---

## ✨ Features

- 🔍 Node health monitoring
- 🔁 Automatic restart on failure
- 📊 Clean logging with timestamps
- ⚙️ Dynamic config detection (mode & network)
- 🧠 AI-powered log analysis
- 📈 Uptime and stability metrics
- 💡 Smart recommendations based on node behavior

---

## 🧠 AI-Powered Analysis

This project includes an AI-inspired analyzer that evaluates node logs and provides insights into node stability.

Instead of blindly restarting nodes, the system analyzes historical behavior and generates:

- Stability status (Stable / Minor instability / Unstable)
- Uptime ratio
- Restart frequency
- Actionable recommendations

This simulates how intelligent agents can participate in decision-making within GenLayer’s ecosystem.

---

## 📊 Example Output

```text
🧠 AI Node Analysis Report
--------------------------
Time: 2026-04-16 19:53:11 UTC

📊 Metrics:
- Total checks: 5
- Downtime events: 1
- Restart events: 1
- Uptime ratio: 0.80

📈 Status:
⚠️ Minor instability

💡 Recommendation:
Monitor closely
```
---

## ⚙️ Setup

Clone the repository:

```bash
git clone https://github.com/Tobu8888/GenLayer-Node-Monitor.git
cd GenLayer-Node-Monitor
```
Make script executable:
<<<<<<< HEAD

```bash
chmod +x monitor.sh
```

---

## ▶️ Usage

Run node monitor:

```bash
./monitor.sh
```
Check logs:

```bash
cat node.log
```
---

## 🧪 Run AI Analysis

Analyze logs:

```bash
python3 ai_analyzer.py
```
Save AI output:

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
*/5 * * * * /path/to/monitor.sh
```

---


## 📁 Project Structure

```bash
.
├── monitor.sh        # Node monitoring + auto-restart
├── ai_analyzer.py    # AI log analysis
├── node.log          # Node logs
├── ai.log            # AI analysis output
└── README.md
```
---

## 🌐 Use Case
- Node operators who want better uptime
- Developers exploring AI + infra integration
- Testing node reliability on GenLayer testnet

---

## 🧩 Alignment with GenLayer

This project demonstrates a simple but practical step toward:

AI-assisted decision-making in blockchain infrastructure

By combining monitoring with analysis and recommendations, it showcases how intelligent systems can enhance node reliability and contribute to decentralized environments.

---

## 🚀 Future Improvements

- 🤖 Real LLM integration (OpenAI / local models)
- 🧠 AI-driven restart decisions (instead of rule-based)
- 📊 Web dashboard (e.g. Vercel)
- 🔔 Alert system (Telegram / Discord)
- 📈 Node scoring system

---

## 📄 License

MIT
=======

```bash
chmod +x monitor.sh
```

---

## ▶️ Usage

Run node monitor:

```bash
./monitor.sh
```
Check logs:

```bash
cat node.log
```
---

## 🧪 Run AI Analysis

Analyze logs:

```bash
python3 ai_analyzer.py
```
Save AI output:

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
*/5 * * * * /path/to/monitor.sh
```

---


## 📁 Project Structure

```bash
.
├── monitor.sh        # Node monitoring + auto-restart
├── ai_analyzer.py    # AI log analysis
├── node.log          # Node logs
├── ai.log            # AI analysis output
└── README.md
```
---

## 🌐 Use Case
- Node operators who want better uptime
- Developers exploring AI + infra integration
- Testing node reliability on GenLayer testnet

---

## 🧩 Alignment with GenLayer

This project demonstrates a simple but practical step toward:

AI-assisted decision-making in blockchain infrastructure

By combining monitoring with analysis and recommendations, it showcases how intelligent systems can enhance node reliability and contribute to decentralized environments.

---

## 🚀 Future Improvements

- 🤖 Real LLM integration (OpenAI / local models)
- 🧠 AI-driven restart decisions (instead of rule-based)
- 📊 Web dashboard (e.g. Vercel)
- 🔔 Alert system (Telegram / Discord)
- 📈 Node scoring system

---

## 📄 License

MIT

---
