#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if command -v launchctl >/dev/null 2>&1; then
  U="gui/$(id -u)"
  for service in com.jarvis.voice com.jarvis.dashboard; do
    launchctl bootstrap "$U" "$HOME/Library/LaunchAgents/$service.plist" 2>/dev/null \
      || launchctl kickstart "$U/$service"
  done
  echo "started via launchd (voice server warms its STT model for ~40s)"
  exit 0
fi

if command -v systemctl >/dev/null 2>&1 && systemctl is-system-running >/dev/null 2>&1; then
  exec systemctl start jarvis-emporio.service
fi

# Docker and minimal Linux: run in the foreground so the container supervisor
# can restart the process and forward its logs/signals.
cd "$ROOT"
exec "${PYTHON:-$ROOT/.venv/bin/python}" server.py
