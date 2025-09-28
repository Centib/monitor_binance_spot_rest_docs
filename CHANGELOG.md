# Changelog

## [v0.1.0] – 2025-09-28

### Added

* Test script `test.sh` to safely simulate upstream changes:

  * Rolls back HEAD (configurable, e.g., `HEAD~5`) for testing diffs.
  * Runs the monitor script.
  * Restores repo to original state, ensuring local changes are not lost.
* Discord notifications now wrap diffs in **code blocks** to preserve formatting and prevent `-` from being rendered as bullets.
* Improved logging with separators and timestamps for better readability.

### Fixed / Improved

* Safe `cd` commands with `|| exit 1` to avoid running in the wrong directory.
* Minor improvements in diff detection and timestamp logging.
* Monitor script handles large diffs more gracefully (optional truncation for Discord messages).

### Notes

* HEAD rollback in `test.sh` ensures diffs are triggered reliably for testing.
* Users can now run `test.sh` to verify diff detection and Discord notifications without affecting the main repo state.
* Diff display in Discord now preserves formatting and prevents unintended Markdown rendering.

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
