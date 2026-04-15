# Claude Code Permission Alerts (macOS) 

<img width="262" height="278" alt="Screenshot 2026-04-14 at 3 09 16 PM" src="https://github.com/user-attachments/assets/71711e8f-b64d-49b8-bffc-03dc19a7b622" />

When Claude Code needs permission, get a native macOS alert with **Allow**, **Always**, and **View** buttons -- no need to switch back to your terminal.

- **Allow** -- approves once, sends keystroke to the correct terminal tab
- **Always** -- shows what it will always allow (e.g. "Always allow Read /tmp/**")
- **View** -- switches to the terminal so you can decide there

## Supported Terminals

- **Terminal.app** -- full support including tab targeting by TTY
- **Warp** -- activate + keystroke
- **iTerm2** -- activate + keystroke
- **VS Code** integrated terminal -- activate + keystroke

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

- `~/.claude/hooks/notify.sh` (alert handler script)
- `PermissionRequest` hook entry in `~/.claude/settings.json`

Existing hooks in your `settings.json` are preserved.
