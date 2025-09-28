# Changelog

## [v0.0.1] – 2025-09-08

### Added

* Initial version of Binance Spot API docs monitor script.
* Monitors `rest-api.md` for changes in the local clone of `binance-spot-api-docs`.
* Logs changes locally in `changes.diff`.
* Optional Discord notifications if `MONITOR_BINANCE_SPOT_REST_DOCS_DISCORD_WEBHOOK` is set.
* Basic test modes:

  * `--check-deps` checks that all required dependencies are installed.
  * `--test-log` writes a test entry to the log.
  * `--test-discord` sends a test message to Discord.
  * `-h`, `--help` show help message and exit
