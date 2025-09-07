#!/usr/bin/env bash
set -euo pipefail

# --- Config ---
REPO_DIR="binance-spot-api-docs"
LOG_FILE="../changes.diff"          # log file outside repo, VS Code-friendly
# Optional: Discord webhook URL as environment variable
# MONITOR_BINANCE_SPOT_REST_DOCS_DISCORD_WEBHOOK="https://discord.com/api/webhooks/XXXX/XXXX"

# --- Clone repo if needed ---
if [ ! -d "$REPO_DIR" ]; then
  git clone https://github.com/binance/binance-spot-api-docs.git "$REPO_DIR"
fi

cd "$REPO_DIR"

# --- Fetch latest remote changes ---
git fetch origin

# --- Timestamp ---
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# --- Check for changes ---
if git diff --quiet origin/master -- rest-api.md; then
    echo "$TIMESTAMP 🟢 No changes in rest-api.md" | tee -a "$LOG_FILE"
else
    echo "$TIMESTAMP 🔴 Changes detected in rest-api.md" | tee -a "$LOG_FILE"
    
    # Save diff to log
    DIFF=$(git diff origin/master -- rest-api.md)
    git diff origin/master -- rest-api.md >> "$LOG_FILE"
    
    # --- Optional: truncate large diffs ---
    MAX_LENGTH=1800
    if [ ${#DIFF} -gt $MAX_LENGTH ]; then
        DIFF="${DIFF:0:$MAX_LENGTH}\n... (truncated)"
    fi

    # --- Send Discord notification if webhook is set ---
    if [ -n "${MONITOR_BINANCE_SPOT_REST_DOCS_DISCORD_WEBHOOK:-}" ]; then
        # Escape diff for JSON
        ESCAPED_DIFF=$(printf '%s' "$DIFF" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')

        curl -H "Content-Type: application/json" \
             -X POST \
             -d "{\"content\": $ESCAPED_DIFF}" \
             "$MONITOR_BINANCE_SPOT_REST_DOCS_DISCORD_WEBHOOK"
    else
        echo "Discord webhook not set, skipping notification."
    fi
fi

# --- Bottom separator ---
echo "------------------------------------------------------------" | tee -a "$LOG_FILE"

# --- Update local file to match remote ---
git checkout origin/master -- rest-api.md
