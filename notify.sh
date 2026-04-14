#!/bin/bash
# Reads Claude Code hook JSON from stdin and sends a desktop notification
# Usage: notify.sh <event_type>
# For permission requests, shows Allow/Deny buttons that send keystrokes to Terminal

EVENT="$1"
INPUT=$(cat)

CLAUDE_TTY="/dev/$(ps -o tty= -p $PPID 2>/dev/null | tr -d ' ')"

send_keystroke() {
  osascript <<EOF
tell application "Terminal"
  -- Find and focus the tab running Claude Code
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
EOF
}

case "$EVENT" in
  stop)
    MSG=$(echo "$INPUT" | /usr/bin/python3 -c "
import sys, json
data = json.load(sys.stdin)
reason = data.get('stop_reason', data.get('stopReason', 'done'))
print(f'Finished ({reason})')
" 2>/dev/null || echo "Ready for input")
    terminal-notifier -message "$MSG" -title "Claude Code" -sound Glass -activate com.apple.Terminal
    ;;

  permission)
    MSG=$(echo "$INPUT" | /usr/bin/python3 -c "
import sys, json
data = json.load(sys.stdin)
tool = data.get('tool_name', 'unknown tool')
tool_input = data.get('tool_input', {})
if tool == 'Bash':
    desc = tool_input.get('description', tool_input.get('command', ''))
elif tool in ('Edit', 'Write', 'Read'):
    desc = tool_input.get('file_path', '')
else:
    desc = json.dumps(tool_input)
if len(desc) > 100:
    desc = desc[:100] + '...'
print(f'{tool}: {desc}')
" 2>/dev/null || echo "Needs permission")

    RESPONSE=$(osascript -e "display alert \"Claude Code\" message \"$MSG\" buttons {\"View\", \"Always\", \"Allow\"} default button \"Allow\" giving up after 30" 2>&1)

    if echo "$RESPONSE" | grep -q "button returned:Allow,"; then
      send_keystroke "1"
    elif echo "$RESPONSE" | grep -q "Always"; then
      send_keystroke "2"
    elif echo "$RESPONSE" | grep -q "View"; then
      # Just focus the correct Terminal tab, no keystroke
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
    fi
    ;;

  elicitation)
    MSG=$(echo "$INPUT" | /usr/bin/python3 -c "
import sys, json
data = json.load(sys.stdin)
msg = data.get('message', data.get('question', 'Has a question'))
if len(msg) > 120:
    msg = msg[:120] + '...'
print(msg)
" 2>/dev/null || echo "Has a question")
    terminal-notifier -message "$MSG" -title "Claude Code" -sound Glass -activate com.apple.Terminal
    ;;

  *)
    terminal-notifier -message "Needs attention" -title "Claude Code" -sound Glass -activate com.apple.Terminal
    ;;
esac
