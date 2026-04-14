#!/bin/bash
# Uninstall Claude Code Desktop Notifications

set -e

SETTINGS="$HOME/.claude/settings.json"
SCRIPT="$HOME/.claude/hooks/notify.sh"

# --- Remove notify.sh ---
if [ -f "$SCRIPT" ]; then
  rm "$SCRIPT"
  echo "Removed $SCRIPT"
else
  echo "notify.sh not found, skipping."
fi

# --- Remove hooks from settings.json ---
if [ -f "$SETTINGS" ]; then
  /usr/bin/python3 << 'PYTHON_EOF'
import json, os

settings_path = os.path.expanduser("~/.claude/settings.json")

with open(settings_path) as f:
    settings = json.load(f)

hooks = settings.get("hooks", {})
removed = []

for event in ["Stop", "PermissionRequest", "Elicitation"]:
    if event in hooks:
        # Only remove if it's our notify.sh hook
        entries = hooks[event]
        if any("notify.sh" in h.get("command", "") for entry in entries for h in entry.get("hooks", [])):
            del hooks[event]
            removed.append(event)

if removed:
    with open(settings_path, "w") as f:
        json.dump(settings, f, indent=2)
        f.write("\n")
    print(f"  Removed hooks: {', '.join(removed)}")
    print(f"  Updated {settings_path}")
else:
    print("  No notification hooks found in settings.json")
PYTHON_EOF
else
  echo "No settings.json found, skipping."
fi

echo ""
echo "Done! Restart Claude Code for changes to take effect."
echo ""
echo "terminal-notifier was left installed. To remove it:"
echo "  brew uninstall terminal-notifier"
