# Claude Code Desktop Notifications (macOS) 

<img width="262" height="278" alt="Screenshot 2026-04-14 at 3 09 16 PM" src="https://github.com/user-attachments/assets/71711e8f-b64d-49b8-bffc-03dc19a7b622" />

Desktop notifications for Claude Code with actionable permission buttons.

- **Stop** -- notification when Claude finishes responding
- **Elicitation** -- notification when Claude asks a question
- **Permission Request** -- popup with **Allow**, **Always**, and **View** buttons that send the keystroke directly to the correct terminal tab

Clicking any notification brings your terminal to focus.

## Supported Terminals

- **Terminal.app** -- full support including tab targeting by TTY
- **Warp** -- activate + keystroke
- **iTerm2** -- activate + keystroke

The terminal is auto-detected via `$TERM_PROGRAM`.

## Install

```bash
bash <(curl -sL https://raw.githubusercontent.com/mikeybrown-8am/claude-code-notifications/main/setup.sh)
```

Or clone and run:

```bash
git clone https://github.com/mikeybrown-8am/claude-code-notifications.git
cd claude-code-notifications
bash setup.sh
```

Then restart Claude Code.

## Reinstall / Update

Run the same install command again. It will overwrite `notify.sh` and update your hooks.

## Uninstall

```bash
bash <(curl -sL https://raw.githubusercontent.com/mikeybrown-8am/claude-code-notifications/main/uninstall.sh)
```

Or if you cloned the repo:

```bash
bash uninstall.sh
```

## Post-install

Your terminal app must be enabled in:

**System Settings > Privacy & Security > Accessibility**

This allows the permission buttons to send keystrokes to your terminal.

## What it installs

- `terminal-notifier` via Homebrew (for banner notifications)
- `~/.claude/hooks/notify.sh` (notification handler script)
- Hook entries in `~/.claude/settings.json` for `Stop`, `PermissionRequest`, and `Elicitation` events

Existing hooks in your `settings.json` are preserved.
