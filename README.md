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
- **kitty** -- per-window keystroke via remote control (requires `allow_remote_control yes` in `kitty.conf`)
- **Xirp / Chirp** desktop app -- per-tab targeting via the app's deep link and tmux

The terminal is auto-detected via `$TERM_PROGRAM` (or `$KITTY_WINDOW_ID` for kitty,
or the tmux session name for Xirp/Chirp).

### Xirp / Chirp

The desktop app sets `TERM_PROGRAM=tmux`, so it cannot be detected the usual way --
without special handling it falls through to the Terminal.app branch and every
button acts on the wrong application. Each of its tabs is a tmux session named
`xirp-<session-uuid>` (or `chirp-<session-uuid>`), which is what identifies the tab:

- **View** opens `xirp://local/?action=open-session&sessionId=<uuid>`. The app's own
  deep-link handler raises the window and selects that tab in one step.
- **Allow** / **Always** go to the asking pane with `tmux send-keys`, never through
  System Events. In a window holding many tabs, a keystroke sent to the *application*
  lands in whichever tab is visible -- which can answer a different session's prompt.
  Before sending, the pane is checked for a live dialog; if the prompt is already gone
  the tab is shown instead of typing a stray digit into the composer.

Unlike the other terminals, alerts are **not** suppressed while the app is frontmost.
Xirp keeps many tabs in one window and exposes no "which tab is visible" signal, so
frontmost does not imply the asking tab is on screen; the cost of notifying anyway is
one dismissible alert, where guessing wrong costs a missed permission prompt.

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
(Not needed for Xirp/Chirp or kitty -- both deliver keystrokes over their own
channel rather than through System Events.)

## What it installs

- `~/.claude/hooks/notify.sh` (alert handler script)
- `PermissionRequest` hook entry in `~/.claude/settings.json`

Existing hooks in your `settings.json` are preserved.
