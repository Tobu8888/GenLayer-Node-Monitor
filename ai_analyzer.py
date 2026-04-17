#!/usr/bin/env python3
"""
GenLayer Node AI Analyzer
Author: Tobu8888
Description: Analyzes GenLayer node logs using the Anthropic API (Claude)
             to provide intelligent insights, stability assessment, and
             actionable recommendations for node operators.
"""

import sys
import re
import json
from datetime import datetime, timezone
from collections import Counter

# ---------- Try importing Anthropic SDK ----------
try:
    import anthropic
    HAS_ANTHROPIC = True
except ImportError:
    HAS_ANTHROPIC = False

# =====================================================
# LOG PARSER
# =====================================================

def parse_log(log_text: str) -> dict:
    """Parse GenLayer node log and extract key metrics."""
    lines = log_text.strip().splitlines()

    metrics = {
        "total_lines": len(lines),
        "inf_count": 0,
        "wrn_count": 0,
        "err_count": 0,
        "synced_blocks": [],
        "restart_events": 0,
        "downtime_events": 0,
        "llm_failures": 0,
        "docker_errors": 0,
        "webdriver_errors": 0,
        "module_failures": 0,
        "network": "unknown",
        "mode": "unknown",
        "operator": "unknown",
        "latest_block": None,
        "error_messages": [],
        "warning_messages": [],
    }

    block_pattern = re.compile(r'blockNumber=(\d+)')
    network_pattern = re.compile(r'network=([\w-]+)')
    mode_pattern = re.compile(r'mode=([\w]+)')
    operator_pattern = re.compile(r'operator=(0x[\w]+)')

    for line in lines:
        # Log levels
        if " INF " in line:
            metrics["inf_count"] += 1
        elif " WRN " in line:
            metrics["wrn_count"] += 1
            metrics["warning_messages"].append(line.strip()[-120:])
        elif " ERR " in line:
            metrics["err_count"] += 1
            metrics["error_messages"].append(line.strip()[-120:])

        # Block numbers
        block_match = block_pattern.search(line)
        if block_match and "GenVM synced" in line:
            metrics["synced_blocks"].append(int(block_match.group(1)))

        # Node metadata
        if metrics["network"] == "unknown":
            net_match = network_pattern.search(line)
            if net_match:
                metrics["network"] = net_match.group(1)

        if metrics["mode"] == "unknown":
            mode_match = mode_pattern.search(line)
            if mode_match:
                metrics["mode"] = mode_match.group(1)

        if metrics["operator"] == "unknown":
            op_match = operator_pattern.search(line)
            if op_match:
                metrics["operator"] = op_match.group(1)

        # Specific events
        if "node started" in line.lower() or "manager process started" in line.lower():
            metrics["restart_events"] += 1

        if "failed to start module" in line.lower() and "Llm" in line:
            metrics["llm_failures"] += 1
            metrics["module_failures"] += 1

        if "permission denied" in line.lower() and "docker" in line.lower():
            metrics["docker_errors"] += 1

        if "webdriver" in line.lower() and ("failed" in line.lower() or "error" in line.lower()):
            metrics["webdriver_errors"] += 1

        if "node is down" in line.lower() or "downtime" in line.lower():
            metrics["downtime_events"] += 1

    # Latest block
    if metrics["synced_blocks"]:
        metrics["latest_block"] = max(metrics["synced_blocks"])

    # Uptime ratio
    total_checks = metrics["inf_count"] + metrics["wrn_count"] + metrics["err_count"]
    if total_checks > 0:
        metrics["uptime_ratio"] = round(
            1.0 - (metrics["downtime_events"] / max(total_checks, 1)), 4
        )
    else:
        metrics["uptime_ratio"] = 1.0

    return metrics


def rule_based_analysis(metrics: dict) -> dict:
    """Fallback rule-based analysis when Anthropic API is unavailable."""
    err = metrics["err_count"]
    wrn = metrics["wrn_count"]
    llm_fail = metrics["llm_failures"]
    docker_err = metrics["docker_errors"]
    uptime = metrics["uptime_ratio"]
    restarts = metrics["restart_events"]

    # Determine stability
    if err == 0 and wrn < 5 and uptime >= 0.95:
        status = "✅ Stable"
        recommendations = [
            "Node is running optimally.",
            "Consider enabling Telegram/Discord alerts for proactive monitoring.",
            "Check if GEN token balance is sufficient for staking (42,000 GEN required).",
        ]
    elif err < 5 and uptime >= 0.80:
        status = "⚠️ Minor Instability"
        recommendations = []
        if llm_fail > 0:
            recommendations.append(f"LLM module failed {llm_fail} time(s). Verify your API key (HEURISTKEY, OPENAIKEY, etc.) is set correctly.")
        if docker_err > 0:
            recommendations.append("Docker permission errors detected. Run: sudo usermod -aG docker $USER then re-login.")
        if wrn > 10:
            recommendations.append("High warning count. Check 'Subscriber channel full' messages — may indicate network congestion.")
        if not recommendations:
            recommendations.append("Monitor closely. Node shows minor issues but is generally stable.")
    else:
        status = "❌ Unstable"
        recommendations = [
            "Node requires immediate attention.",
            "Check logs: cat node.log | tail -100",
            "Try restarting: ./monitor.sh",
        ]
        if restarts > 3:
            recommendations.append(f"Node restarted {restarts} times. Investigate root cause before next restart.")
        if llm_fail > 3:
            recommendations.append("Persistent LLM failures. Switch to a different provider or verify API credits.")

    return {
        "status": status,
        "recommendations": recommendations,
        "analysis_source": "Rule-based (offline)",
    }


def ai_analysis(metrics: dict, log_sample: str) -> dict:
    """Use Claude (Anthropic API) for intelligent log analysis."""
    if not HAS_ANTHROPIC:
        return rule_based_analysis(metrics)

    client = anthropic.Anthropic()

    prompt = f"""You are an expert DevOps engineer specializing in blockchain node operations, specifically GenLayer nodes.

Analyze the following GenLayer node metrics and log sample, then provide:
1. A stability assessment (Stable / Minor Instability / Unstable)
2. Key issues identified
3. Specific actionable recommendations

Node Metrics:
{json.dumps(metrics, indent=2)}

Recent Log Sample (last 20 lines):
{log_sample}

Respond in this exact JSON format:
{{
  "status": "✅ Stable | ⚠️ Minor Instability | ❌ Unstable",
  "key_issues": ["issue1", "issue2"],
  "recommendations": ["rec1", "rec2", "rec3"],
  "summary": "One paragraph summary of node health"
}}

Be specific and technical. Reference actual values from the metrics."""

    try:
        message = client.messages.create(
            model="claude-sonnet-4-6",
            max_tokens=1000,
            messages=[{"role": "user", "content": prompt}]
        )

        response_text = message.content[0].text
        # Extract JSON from response
        json_match = re.search(r'\{.*\}', response_text, re.DOTALL)
        if json_match:
            result = json.loads(json_match.group())
            result["analysis_source"] = "Claude AI (Anthropic)"
            return result
        else:
            raise ValueError("No JSON found in response")

    except Exception as e:
        # Fallback to rule-based
        result = rule_based_analysis(metrics)
        result["analysis_source"] = f"Rule-based (AI error: {str(e)[:50]})"
        return result


def print_report(metrics: dict, analysis: dict):
    """Print formatted analysis report."""
    now = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S UTC")

    print()
    print("=" * 50)
    print("🧠 GenLayer Node AI Analysis Report")
    print("=" * 50)
    print(f"Time     : {now}")
    print(f"Network  : {metrics['network']}")
    print(f"Mode     : {metrics['mode']}")
    print(f"Operator : {metrics['operator'][:20]}..." if len(metrics['operator']) > 20 else f"Operator : {metrics['operator']}")
    print(f"Source   : {analysis.get('analysis_source', 'Unknown')}")
    print()
    print("📊 Metrics:")
    print(f"  - Total log lines   : {metrics['total_lines']}")
    print(f"  - INFO events       : {metrics['inf_count']}")
    print(f"  - WARNING events    : {metrics['wrn_count']}")
    print(f"  - ERROR events      : {metrics['err_count']}")
    print(f"  - LLM failures      : {metrics['llm_failures']}")
    print(f"  - Docker errors     : {metrics['docker_errors']}")
    print(f"  - Restart events    : {metrics['restart_events']}")
    print(f"  - Downtime events   : {metrics['downtime_events']}")
    print(f"  - Uptime ratio      : {metrics['uptime_ratio']:.2%}")
    if metrics['latest_block']:
        print(f"  - Latest block      : {metrics['latest_block']:,}")
    print()
    print(f"📈 Status:")
    print(f"  {analysis.get('status', 'Unknown')}")
    print()

    # Key issues (AI mode)
    if "key_issues" in analysis and analysis["key_issues"]:
        print("🔍 Key Issues:")
        for issue in analysis["key_issues"]:
            print(f"  • {issue}")
        print()

    # Summary (AI mode)
    if "summary" in analysis:
        print("📝 Summary:")
        print(f"  {analysis['summary']}")
        print()

    # Recommendations
    print("💡 Recommendations:")
    for rec in analysis.get("recommendations", []):
        print(f"  → {rec}")

    print()
    print("=" * 50)
    print()


# =====================================================
# MAIN
# =====================================================

def find_node_log() -> str:
    """Auto-detect GenLayer node log file location."""
    import os
    import glob

    # Priority order of log locations
    candidates = [
        # GenLayer node actual log files
        os.path.expanduser("~/v0.5.8/genlayer-node-linux-amd64/data/node/logs/*.log"),
        os.path.expanduser("~/v0.5.*/genlayer-node-linux-amd64/data/node/logs/*.log"),
        os.path.expanduser("~/genlayer-node-linux-amd64/data/node/logs/*.log"),
        # Fallback: node.log in current dir
        os.path.join(os.path.dirname(os.path.abspath(__file__)), "node.log"),
        "./node.log",
    ]

    for pattern in candidates:
        matches = glob.glob(pattern)
        if matches:
            # Pick the most recently modified file
            latest = max(matches, key=os.path.getmtime)
            return latest

    return None


def main():
    import os

    # Read log from stdin or auto-detect file
    if not sys.stdin.isatty():
        log_text = sys.stdin.read()
        log_source = "stdin"
    else:
        log_path = find_node_log()
        if log_path:
            print(f"📂 Reading log from: {log_path}")
            with open(log_path, "r", errors="replace") as f:
                log_text = f.read()
            log_source = log_path
        else:
            print("❌ Could not find GenLayer node log.")
            print("Usage: cat /path/to/node.log | python3 ai_analyzer.py")
            sys.exit(1)

    if not log_text.strip():
        print("⚠️  Log is empty. Nothing to analyze.")
        sys.exit(0)

    # Parse metrics
    metrics = parse_log(log_text)

    # Get last 20 lines as sample for AI
    log_sample = "\n".join(log_text.strip().splitlines()[-20:])

    # Run analysis
    if HAS_ANTHROPIC:
        analysis = ai_analysis(metrics, log_sample)
    else:
        analysis = rule_based_analysis(metrics)

    # Print report
    print_report(metrics, analysis)


if __name__ == "__main__":
    main()
