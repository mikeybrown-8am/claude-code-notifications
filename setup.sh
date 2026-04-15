#!/bin/bash
# Claude Code Desktop Notifications Setup (macOS)
#
# What this does:
#   - Permission requests show a popup with Allow / Always / View buttons
#     that send the keystroke back to the correct terminal tab
#
# Supports: Terminal.app, Warp, iTerm2
# Requirements: macOS
# Accessibility: Your terminal must be enabled in System Settings > Privacy & Security > Accessibility

set -e

HOOKS_DIR="$HOME/.claude/hooks"
SETTINGS="$HOME/.claude/settings.json"
SCRIPT="$HOOKS_DIR/notify.sh"
REPO_URL="https://raw.githubusercontent.com/mikeybrown-8am/claude-code-notifications/main"

# --- Create hooks directory ---
mkdir -p "$HOOKS_DIR"

# --- Download or copy notify.sh ---
# If running from the cloned repo, copy locally; otherwise download
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$SCRIPT_DIR/notify.sh" ]; then
  cp "$SCRIPT_DIR/notify.sh" "$SCRIPT"
else
  curl -sL "$REPO_URL/notify.sh" -o "$SCRIPT"
fi
chmod +x "$SCRIPT"
echo "Wrote $SCRIPT"

# --- Merge hooks into settings.json ---
/usr/bin/python3 << 'PYTHON_EOF'
import json, os

settings_path = os.path.expanduser("~/.claude/settings.json")
hook_script = os.path.expanduser("~/.claude/hooks/notify.sh")

# Load existing settings or start fresh
if os.path.exists(settings_path):
    with open(settings_path) as f:
        settings = json.load(f)
else:
    settings = {}

hooks = settings.setdefault("hooks", {})

new_hooks = {
    "PermissionRequest": [{"hooks": [{"type": "command", "command": f"{hook_script} permission", "async": True}]}],
}

for event, config in new_hooks.items():
    if event not in hooks:
        hooks[event] = config
        print(f"  Added {event} hook")
    else:
        # Replace existing notification hooks, preserve others
        entries = hooks[event]
        is_ours = any("notify.sh" in h.get("command", "") for entry in entries for h in entry.get("hooks", []))
        if is_ours:
            hooks[event] = config
            print(f"  Updated {event} hook")
        else:
            hooks[event].extend(config)
            print(f"  Added {event} hook (preserved existing)")

with open(settings_path, "w") as f:
    json.dump(settings, f, indent=2)
    f.write("\n")

print(f"Updated {settings_path}")
print()
PYTHON_EOF

echo ""
echo "Done! Restart Claude Code to activate."
echo ""
echo "Note: Your terminal app must be enabled in:"
echo "  System Settings > Privacy & Security > Accessibility"
echo "for the permission buttons to send keystrokes."
