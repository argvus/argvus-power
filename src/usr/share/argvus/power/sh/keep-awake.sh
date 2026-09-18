#!/usr/bin/env sh
# Keep the graphical session awake by stopping ARGVUS hypridle.
# Usage: keep-awake.sh [status|on|off|toggle]

set -eu

ARGVUS_CONFIG_HOME="${ARGVUS_CONFIG_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}}"
STATE_DIR="$ARGVUS_CONFIG_HOME/argvus"
STATE_FILE="$STATE_DIR/.keep-awake"

status() {
  [ -f "$STATE_FILE" ] && [ "$(sed -n '1p' "$STATE_FILE")" = enabled ]
}

set_state() {
  state="$1"
  mkdir -p "$STATE_DIR"
  if [ "$state" = enabled ]; then
    systemctl --user stop argvus-hypridle.service >/dev/null 2>&1 || true
    printf '%s\n' enabled > "$STATE_FILE"
  else
    rm -f "$STATE_FILE"
    systemctl --user start argvus-hypridle.service >/dev/null 2>&1 || true
  fi
}

case "${1:-status}" in
  status)
    if status; then printf '%s\n' enabled; else printf '%s\n' disabled; fi
    ;;
  on) set_state enabled; printf '%s\n' enabled ;;
  off) set_state disabled; printf '%s\n' disabled ;;
  toggle)
    if status; then set_state disabled; printf '%s\n' disabled
    else set_state enabled; printf '%s\n' enabled
    fi
    ;;
  *) printf 'Usage: %s [status|on|off|toggle]\n' "$0" >&2; exit 2 ;;
esac
