#!/bin/bash
# Daily brew catalog update

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

LOG_FILE="$HOME/.brew-update.log"

{
  echo "=== Brew update: $(date) ==="
  /opt/homebrew/bin/brew update 2>&1
  echo ""
} >> "$LOG_FILE"

# Keep log file under 1MB
if [ -f "$LOG_FILE" ] && [ "$(stat -f%z "$LOG_FILE" 2>/dev/null || echo 0)" -gt 1048576 ]; then
  tail -n 500 "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
fi
