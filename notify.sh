#!/bin/bash
# Reads Claude Code hook JSON from stdin and sends a desktop notification
# Usage: notify.sh <event_type>
# For permission requests, shows Allow/Always/View buttons that send keystrokes to Terminal
# Supports: Terminal.app, Warp, iTerm2

EVENT="$1"
INPUT=$(cat)

# Detect terminal app
case "${TERM_PROGRAM:-}" in
  WarpTerminal)
    APP_NAME="Warp"
    BUNDLE_ID="dev.warp.Warp-Stable"
    ;;
  iTerm.app|iTerm2)
    APP_NAME="iTerm2"
    BUNDLE_ID="com.googlecode.iterm2"
    ;;
  vscode)
    APP_NAME="Code"
    BUNDLE_ID="com.microsoft.VSCode"
    ;;
  *)
    APP_NAME="Terminal"
    BUNDLE_ID="com.apple.Terminal"
    ;;
esac

CLAUDE_TTY="/dev/$(ps -o tty= -p $PPID 2>/dev/null | tr -d ' ')"

focus_tab() {
  if [ "$APP_NAME" = "Terminal" ]; then
    # Terminal.app supports finding tabs by TTY
    osascript <<EOF
tell application "Terminal"
  repeat with w in windows
    repeat with t in tabs of w
      if tty of t is "$CLAUDE_TTY" then
        set selected of t to true
        set index of w to 1
      end if
    end repeat
  end repeat
  activate
end tell
EOF
  else
    osascript -e "tell application \"$APP_NAME\" to activate"
  fi
}

send_keystroke() {
  # Send keystroke to the correct terminal tab, then return to previous app
  if [ "$APP_NAME" = "Terminal" ]; then
    osascript <<EOF
set prevApp to path to frontmost application as text
tell application "Terminal"
  repeat with w in windows
    repeat with t in tabs of w
      if tty of t is "$CLAUDE_TTY" then
        set selected of t to true
        set index of w to 1
      end if
    end repeat
  end repeat
  activate
end tell
tell application "System Events"
  tell process "Terminal"
    keystroke "$1"
  end tell
end tell
activate application prevApp
EOF
  else
    osascript <<EOF
set prevApp to path to frontmost application as text
tell application "$APP_NAME" to activate
tell application "System Events"
  tell process "$APP_NAME"
    keystroke "$1"
  end tell
end tell
activate application prevApp
EOF
  fi
}

case "$EVENT" in
  permission)
    PARSED=$(echo "$INPUT" | /usr/bin/python3 -c "
import sys, json
data = json.load(sys.stdin)
tool = data.get('tool_name', 'unknown tool')
tool_input = data.get('tool_input', {})
if tool == 'Bash':
    cmd = tool_input.get('command', '')
    description = tool_input.get('description', '')
    if description:
        desc = f'{description}\n\n{cmd}'
    else:
        desc = cmd
elif tool in ('Edit', 'Write', 'Read'):
    desc = tool_input.get('file_path', '')
else:
    desc = json.dumps(tool_input)

# Extract what 'Always' would allow from permission_suggestions
always = ''
suggestions = data.get('permission_suggestions', [])
for s in suggestions:
    stype = s.get('type', '')
    if stype == 'addRules' and s.get('behavior') == 'allow':
        rules = s.get('rules', [])
        if rules:
            r = rules[0]
            tool_name = r.get('toolName', '')
            rule = r.get('ruleContent', '')
            if tool_name and rule:
                rule = rule.replace('//', '/')
                always = f'Always allow {tool_name} {rule}'
            elif tool_name:
                always = f'Always allow {tool_name}'
if not always and suggestions:
    always = 'Always'

# JSON output so bash can parse both fields cleanly
import json as j
print(j.dumps({'msg': f'{tool}: {desc}', 'always': always}))
" 2>/dev/null)

    MSG=$(echo "$PARSED" | /usr/bin/python3 -c "import sys,json; print(json.load(sys.stdin)['msg'])" 2>/dev/null || echo "Needs permission")
    ALWAYS_LABEL=$(echo "$PARSED" | /usr/bin/python3 -c "import sys,json; print(json.load(sys.stdin)['always'])" 2>/dev/null || echo "")

    if [ -n "$ALWAYS_LABEL" ]; then
      RESPONSE=$(osascript -e "display alert \"Claude Code\" message \"$MSG\" buttons {\"View\", \"$ALWAYS_LABEL\", \"Allow\"} default button \"Allow\" giving up after 30" 2>&1)
    else
      RESPONSE=$(osascript -e "display alert \"Claude Code\" message \"$MSG\" buttons {\"View\", \"Allow\"} default button \"Allow\" giving up after 30" 2>&1)
    fi

    if echo "$RESPONSE" | grep -q "button returned:Allow"; then
      send_keystroke "1"
    elif echo "$RESPONSE" | grep -q "button returned:Always"; then
      send_keystroke "2"
    elif echo "$RESPONSE" | grep -q "button returned:View"; then
      focus_tab
    fi
    ;;

  *)
    # No notification for other events
    ;;
esac
