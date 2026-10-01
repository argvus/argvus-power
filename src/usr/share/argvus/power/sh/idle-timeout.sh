#!/usr/bin/env sh
# Configure the inactivity lock timeout used by hypridle.
# Usage: idle-timeout.sh [status|60|300|600|900|1800|0]
# Values are in seconds; 0 disables the idle lock ("Nunca").
# shellcheck disable=SC1090,SC1091

set -u

start=0; end=0; tline=0; tval=0

ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/session/sh/bootstrap.sh}"
. "$ARGVUS_BOOTSTRAP"
# shellcheck disable=SC1091
. /usr/share/argvus/lib/i18n.sh
# shellcheck disable=SC2034
ARGVUS_MUTABLE_CONFIG=1

STATE_DIR="${ARGVUS_CONFIG_HOME}/argvus/data"
TIMEOUT_FILE="${STATE_DIR}/.idle-timeout"
HYPRIDLE_FILE="$(paths_config power/config/hypridle.conf)"
DEFAULT_TIMEOUT=300
RUNTIME=1

# Prints "start end timeout_line timeout_value" for the lock listener block,
# or nothing when no lock listener exists. The lock listener is the
# `listener { }` block whose on-timeout command targets the screen lock.
lock_listener_info() {
  awk '
    /^[[:space:]]*listener[[:space:]]*\{/ { in_listener=1; start=NR; tline=0; tval=0; lock_seen=0 }
    in_listener && /^[[:space:]]*timeout[[:space:]]*=/ && tline == 0 {
      tline=NR
      tval=$0; sub(/^[[:space:]]*timeout[[:space:]]*=[[:space:]]*/, "", tval); sub(/[[:space:]].*$/, "", tval)
    }
    in_listener && /^[[:space:]]*on-timeout[[:space:]]*=/ {
      v=$0; sub(/^[[:space:]]*on-timeout[[:space:]]*=[[:space:]]*/, "", v)
      if (tolower(v) ~ /lock/) lock_seen=1
    }
    in_listener && /^[[:space:]]*\}/ {
      if (lock_seen) { print start, NR, tline, tval; exit }
      in_listener=0
    }
  ' "$HYPRIDLE_FILE"
}

# Loads the lock listener coordinates into start/end/tline/tval.
# Returns 1 when no lock listener exists.
read_lock_listener() {
  info="$(lock_listener_info)" || return 1
  [ -n "$info" ] || return 1
  IFS=' ' read -r start end tline tval <<EOF
$info
EOF
  case "$start" in
    ''|*[!0-9]*) return 1 ;;
  esac
}

# Prints the user-configured lock command, or the ARGVUS default.
lock_command() {
  awk '
    /^[[:space:]]*general[[:space:]]*\{/ { in_general=1 }
    in_general && /^[[:space:]]*lock_cmd[[:space:]]*=/ {
      v=$0; sub(/^[[:space:]]*lock_cmd[[:space:]]*=[[:space:]]*/, "", v); sub(/[[:space:]]*$/, "", v)
      print v; exit
    }
    in_general && /^[[:space:]]*\}/ { in_general=0 }
  ' "$HYPRIDLE_FILE"
}

read_timeout() {
  if [ -f "$HYPRIDLE_FILE" ]; then
    if read_lock_listener; then
      printf '%s\n' "$tval"
    else
      printf '0\n'
    fi
    return 0
  fi

  if [ -s "$TIMEOUT_FILE" ]; then
    sed -n '1p' "$TIMEOUT_FILE"
    return 0
  fi

  printf '%s\n' "$DEFAULT_TIMEOUT"
}

select_timeout() {
  rofi -config "$(paths_config launcher/config/config.rasi)" -dmenu \
    -p "$(argvus_tr power idle.timeout.title)" -i \
    -theme-str 'listview {lines: 6;}' <<EOF
01 - $(argvus_tr power idle.timeout.one_minute)
02 - $(argvus_tr power idle.timeout.minutes count=5)
03 - $(argvus_tr power idle.timeout.minutes count=10)
04 - $(argvus_tr power idle.timeout.minutes count=15)
05 - $(argvus_tr power idle.timeout.minutes count=30)
06 - $(argvus_tr power idle.timeout.never)
EOF
}

normalize_timeout() {
  case "$1" in
    0|0m|0min|*"Never"|*"Nunca"|06*)
      TIMEOUT=0; LABEL="$(argvus_tr power idle.timeout.never)" ;;
    60|1m|1min|*"1 minute"|*"1 minuto"|01*)
      TIMEOUT=60; LABEL="$(argvus_tr power idle.timeout.one_minute)" ;;
    300|5m|5min|*" 5 minutes"|*" 5 minutos"|02*)
      TIMEOUT=300; LABEL="$(argvus_tr power idle.timeout.minutes count=5)" ;;
    600|10m|10min|*"10 minutes"|*"10 minutos"|03*)
      TIMEOUT=600; LABEL="$(argvus_tr power idle.timeout.minutes count=10)" ;;
    900|15m|15min|*"15 minutes"|*"15 minutos"|04*)
      TIMEOUT=900; LABEL="$(argvus_tr power idle.timeout.minutes count=15)" ;;
    1800|30m|30min|*"30 minutes"|*"30 minutos"|05*)
      TIMEOUT=1800; LABEL="$(argvus_tr power idle.timeout.minutes count=30)" ;;
    *) return 1 ;;
  esac
}

append_lock_listener() {
  cmd="$(lock_command)"
  cmd="${cmd:-sh /usr/share/argvus/power/sh/hypr-power-menu.sh --lock}"
  cat >> "$HYPRIDLE_FILE" <<EOF

# Screen-lock timer (managed by ARGVUS Control Center)
listener {
  timeout = ${TIMEOUT}
  on-timeout = ${cmd}
}
EOF
}

apply_timeout() {
  [ -f "$HYPRIDLE_FILE" ] || {
    argvus_tr power idle.timeout.config_missing "path=$HYPRIDLE_FILE" >&2
    exit 1
  }

  if [ "$TIMEOUT" = 0 ]; then
    if read_lock_listener; then
      sed -i "${start},${end}d" "$HYPRIDLE_FILE"
    fi
  elif read_lock_listener; then
    if [ "$tline" -gt 0 ]; then
      sed -i "${tline}s/^[[:space:]]*timeout[[:space:]]*=.*/  timeout = ${TIMEOUT}/" "$HYPRIDLE_FILE"
    else
      append_lock_listener
    fi
  else
    append_lock_listener
  fi

  mkdir -p "$STATE_DIR"
  printf '%s\n' "$TIMEOUT" > "$TIMEOUT_FILE"
}

refresh_runtime() {
  command -v argvus-sessionctl >/dev/null 2>&1 || return 0
  argvus-sessionctl restart hypridle >/dev/null 2>&1 || true
}

case "${1:-}" in
  status)
    read_timeout
    exit 0
    ;;
  --apply-static)
    RUNTIME=0
    REQUESTED="$(read_timeout)"
    ;;
  '')
    REQUESTED="$(select_timeout)"
    [ -n "$REQUESTED" ] || exit 0
    ;;
  *)
    REQUESTED="$1"
    ;;
esac

if [ "${ARGVUS_NO_RUNTIME:-0}" = 1 ]; then
  RUNTIME=0
fi

if ! normalize_timeout "$REQUESTED"; then
  argvus_tr power idle.timeout.invalid "timeout=$REQUESTED" >&2
  exit 1
fi

apply_timeout
[ "$RUNTIME" -eq 1 ] && refresh_runtime
notify-send "$(argvus_tr power idle.timeout.title)" \
  "$(argvus_tr power idle.timeout.notification "timeout=$LABEL")" 2>/dev/null || true
printf '%s\n' "$TIMEOUT"
