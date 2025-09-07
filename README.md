# monitor_binance_spot_rest_docs

A simple monitoring tool that checks for changes in Binance Spot REST API documentation (`rest-api.md`) and logs differences over time.  
Optionally, it can send change notifications to a Discord channel via webhook.

---

## Features

- Detects changes in [`rest-api.md`](https://github.com/binance/binance-spot-api-docs/blob/master/rest-api.md).
- Logs changes in standard **git diff** format (easy to read in VS Code or any diff viewer).
- Optional Discord notifications when changes are detected.
- Minimal dependencies (just `git`, `bash`, and `curl`).

---

## How It Works

- On each run, the script:
  1. Fetches the latest Binance Spot REST API docs.
  2. Compares `rest-api.md` against the latest `origin/master`.
  3. Logs whether changes were detected into `changes.diff`.
  4. If Discord is enabled, posts a message to your channel when changes occur.
  5. Updates the local copy of `rest-api.md` for the next run.

---

## Installation

Clone this repository:

```bash
git clone https://github.com/yourusername/monitor_binance_spot_rest_docs.git
cd monitor_binance_spot_rest_docs
chmod +x monitor.sh
```

---

## Usage

Run the script manually:

```bash
./monitor.sh
```

Output will be stored in `changes.diff` (next to the repo).

---

## Discord Notifications (Optional)

If you want notifications in a Discord server:

1. Create a **Discord Webhook** (Server Settings → Integrations → Webhooks).
2. Copy the Webhook URL.
3. Set it as an environment variable:

```bash
export MONITOR_BINANCE_SPOT_REST_DOCS_DISCORD_WEBHOOK="https://discord.com/api/webhooks/...."
```

4. Run the script again.

   - If changes are detected, a message will be sent to Discord.
   - If no webhook is configured, only the local log is updated.

---

## Automation

You can run this script on a schedule with **cron**:

```bash
crontab -e
```

Example (run every day at 10:00):

```
0 10 * * * /path/to/monitor_binance_spot_rest_docs/monitor.sh
```

Logs will continue to append to `changes.diff`.

---

## Example Output

When no changes:

```
2025-09-07 15:12:42 🟢 No changes in rest-api.md
```

When changes detected:

```
2025-09-07 15:12:42 🔴 Changes detected in rest-api.md
diff --git a/rest-api.md b/rest-api.md
index 0f0d65a..3fccc67 100644
--- a/rest-api.md
+++ b/rest-api.md
@@ -139,7 +139,7 @@ Sample Payload below:

 ### General Info on Limits
-* SECOND => S
+* SECONS => S
```

---

## Requirements

- `bash`
- `git`
- `curl` (only required if using Discord notifications)
- (Optional) Docker

---

## License

MIT
