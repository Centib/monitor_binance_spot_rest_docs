#!/usr/bin/env bash
set -euo pipefail

# Go to repo
cd binance-spot-api-docs || exit 1

# Backup current HEAD
CURRENT_HEAD=$(git rev-parse HEAD)

# Rollback one commit to simulate upstream changes
git reset --hard HEAD~5

# Run the monitor script
../monitor.sh

# Restore original HEAD
git reset --hard "$CURRENT_HEAD"

echo "Test complete."
