# Claude Code Desktop Notifications (macOS)

Desktop notifications for Claude Code with actionable permission buttons.

- **Stop** -- notification when Claude finishes responding
- **Elicitation** -- notification when Claude asks a question
- **Permission Request** -- popup with **Allow**, **Always**, and **View** buttons that send the keystroke directly to the correct Terminal tab

Clicking any notification brings Terminal.app to focus.

## Requirements

- macOS
- Terminal.app
- [Homebrew](https://brew.sh)

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

## Post-install

You must enable **Terminal** in:

**System Settings > Privacy & Security > Accessibility**

This allows the permission buttons to send keystrokes to Terminal.

## What it installs

- `terminal-notifier` via Homebrew (for banner notifications)
- `~/.claude/hooks/notify.sh` (notification handler script)
- Hook entries in `~/.claude/settings.json` for `Stop`, `PermissionRequest`, and `Elicitation` events

Existing hooks in your `settings.json` are preserved.

## Uninstall

Remove the `Stop`, `PermissionRequest`, and `Elicitation` entries from `~/.claude/settings.json`, then:

```bash
rm ~/.claude/hooks/notify.sh
brew uninstall terminal-notifier  # optional
```
