import sys
from datetime import datetime, UTC

def analyze_log(log_text):
    lines = log_text.splitlines()

    total_checks = 0
    down_events = 0
    restart_events = 0

    for line in lines:
        if "Checking node" in line:
            total_checks += 1
        if "Status: DOWN" in line:
            down_events += 1
        if "Restart" in line or "restarted" in line:
            restart_events += 1

    # ===== BASIC ANALYSIS =====
    if total_checks == 0:
        return "⚠️ No data available"

    uptime_ratio = (total_checks - down_events) / total_checks

    # ===== DECISION =====
    if uptime_ratio > 0.95:
        status = "✅ Stable"
        recommendation = "No action needed"
    elif uptime_ratio > 0.80:
        status = "⚠️ Minor instability"
        recommendation = "Monitor closely"
    else:
        status = "❌ Unstable"
        recommendation = "Investigate node performance"

    # ===== BUILD REPORT =====
    report = f"""
🧠 AI Node Analysis Report
--------------------------
Time: {datetime.now(UTC).strftime('%Y-%m-%d %H:%M:%S')} UTC

📊 Metrics:
- Total checks: {total_checks}
- Downtime events: {down_events}
- Restart events: {restart_events}
- Uptime ratio: {uptime_ratio:.2f}

📈 Status:
{status}

💡 Recommendation:
{recommendation}
"""
    return report.strip()


# ===== MAIN =====
if __name__ == "__main__":
    if not sys.stdin.isatty():
        log_data = sys.stdin.read()
    else:
        try:
            with open("node.log", "r") as f:
                log_data = f.read()
        except FileNotFoundError:
            print("❌ node.log not found")
            sys.exit(1)

    result = analyze_log(log_data)
    print(result)
