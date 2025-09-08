#!/usr/bin/env bash
set -euo pipefail

# --- Config ---
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)" # absolute path of script dir
REPO_DIR="$SCRIPT_DIR/binance-spot-api-docs"
LOG_FILE="$SCRIPT_DIR/changes.diff" # log file always relative to script dir
# MONITOR_BINANCE_SPOT_REST_DOCS_DISCORD_WEBHOOK="https://discord.com/api/webhooks/XXXX/XXXX"

# --- Helper functions ---
log() {
    echo "$1" | tee -a "$LOG_FILE"
}
log_separator() {
    log "------------------------------------------------------------"
}

# --- Help ---
show_help() {
    cat <<EOF
Usage: ./monitor.sh [options]

Options:
  --test-log       Write a test entry to the log file
  --test-discord   Send a test message to Discord (if webhook is set)
  -h, --help       Show this help message and exit

Environment:
  MONITOR_BINANCE_SPOT_REST_DOCS_DISCORD_WEBHOOK   Discord webhook URL (optional).
                                                   If not set, only local logging is used.

Description:
  This script monitors the Binance Spot REST API docs (rest-api.md) for changes.
  - Logs changes into $LOG_FILE
  - Optionally sends changes to Discord if a webhook is configured
EOF
}

# --- Argument handling ---
case "${1:-}" in
-h | --help)
    show_help
    exit 0
    ;;
--test-log)
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    log "$TIMESTAMP 🔵 Log test message from monitor script"
    log_separator
    exit 0
    ;;
--test-discord)
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    TEST_MSG="$TIMESTAMP 🔵 Discord test message from monitor script"
    if [ -n "${MONITOR_BINANCE_SPOT_REST_DOCS_DISCORD_WEBHOOK:-}" ]; then
        ESCAPED_MSG=$(printf '%s' "$TEST_MSG" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')
        curl -s -H "Content-Type: application/json" \
            -X POST \
            -d "{\"content\": $ESCAPED_MSG}" \
            "$MONITOR_BINANCE_SPOT_REST_DOCS_DISCORD_WEBHOOK" >/dev/null
        log "$TIMESTAMP 🔵 Discord webhook test sent successfully"
    else
        log "$TIMESTAMP 🟡 Discord webhook not set, skipping test"
    fi
    log_separator
    exit 0
    ;;
esac

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
    log "$TIMESTAMP 🟢 No changes in rest-api.md"
else
    HEADER="$TIMESTAMP 🔴 Changes detected in rest-api.md"
    log "$HEADER"

    # Save diff to log
    DIFF=$(git diff origin/master -- rest-api.md)
    echo "$DIFF" >>"$LOG_FILE"

    # --- Optional: truncate large diffs ---
    MAX_LENGTH=1800
    if [ ${#DIFF} -gt $MAX_LENGTH ]; then
        DIFF="${DIFF:0:$MAX_LENGTH}\n... (truncated)"
    fi

    # --- Send Discord notification if webhook is set ---
    if [ -n "${MONITOR_BINANCE_SPOT_REST_DOCS_DISCORD_WEBHOOK:-}" ]; then
        PAYLOAD="$HEADER\n$DIFF"
        ESCAPED_PAYLOAD=$(printf '%s' "$PAYLOAD" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')
        curl -s -H "Content-Type: application/json" \
            -X POST \
            -d "{\"content\": $ESCAPED_PAYLOAD}" \
            "$MONITOR_BINANCE_SPOT_REST_DOCS_DISCORD_WEBHOOK" >/dev/null
    else
        log "$TIMESTAMP 🟡 Discord webhook not set, skipping notification"
    fi
fi

log_separator

# --- Update local file to match remote ---
git checkout origin/master -- rest-api.md
