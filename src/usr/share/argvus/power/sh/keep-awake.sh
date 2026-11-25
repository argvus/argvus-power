#!/usr/bin/env sh
# Keep the graphical session awake by stopping ARGVUS hypridle.
# Usage: keep-awake.sh [status|on|off|toggle]
# shellcheck disable=SC1091

. /usr/share/argvus/lib/i18n.sh

set -eu

ARGVUS_CONFIG_HOME="${ARGVUS_CONFIG_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}}"
export ARGVUS_CONFIG_HOME
STATE_DIR="$ARGVUS_CONFIG_HOME/argvus/data"
LEGACY_FILE="$STATE_DIR/.keep-awake"
STATE_FILE="$STATE_DIR/power/.keep-awake"
UNIT=argvus-hypridle.service
PENDING_FILE="$STATE_DIR/internal/keep-awake.pending"

marker_enabled() {
  [ -f "$1" ] && [ "$(sed -n '1p' "$1")" = enabled ]
}

requested() {
  value="$(argvus config get /power/keep_awake --raw)" || return 1
  case "$value" in
    true) printf '%s\n' enabled ;;
    false) printf '%s\n' disabled ;;
    null|'')
      if [ -f "$STATE_FILE" ]; then
        if marker_enabled "$STATE_FILE"; then printf '%s\n' enabled; else printf '%s\n' disabled; fi
      elif marker_enabled "$LEGACY_FILE"; then printf '%s\n' enabled
      else printf '%s\n' disabled
      fi ;;
    *) return 1 ;;
  esac
}

observe() (
  details="$(systemctl --user show "$UNIT" -p LoadState -p ActiveState -p MainPID)" || return 1
  case "$details" in
    *'LoadState=loaded'*) ;;
    *) return 1 ;;
  esac
  case "$details" in
    *'ActiveState=active'*)
      pid="$(printf '%s\n' "$details" | sed -n 's/^MainPID=//p')"
      case "$pid" in
        ''|0|*[!0-9]*) printf '%s\n' starting ;;
        *)
          if [ "$(cat "/proc/$pid/comm" 2>/dev/null)" = hypridle ]; then
            printf '%s\n' active
          else
            printf '%s\n' starting
          fi ;;
      esac ;;
    *'ActiveState=inactive'*) printf '%s\n' inactive ;;
    *'ActiveState=failed'*) printf '%s\n' failed ;;
    *) return 1 ;;
  esac
)

publish_marker() (
  target="$1"
  marker_value="$2"
  temporary="$(mktemp "${target}.XXXXXX")" || exit 1
  trap 'rm -f -- "$temporary"' EXIT
  printf '%s\n' "$marker_value" > "$temporary" && mv -fT -- "$temporary" "$target"
)

set_state() {
  state="$1"
  observe >/dev/null || return 1
  mkdir -p "$STATE_DIR/power" || return 1
  case "$state" in
    enabled) preference=true; action=stop; expected=inactive ;;
    disabled) preference=false; action=start; expected=active ;;
  esac
  # Commit the request first so the session can start Hypridle when disabling.
  # Keep that request after a partial failure so an explicit retry is safe.
  publish_marker "$PENDING_FILE" "$state" || return 1
  argvus config set /power/keep_awake "$preference" || return 1
  publish_marker "$STATE_FILE" "$state" || return 1
  [ "$(requested)" = "$state" ] || return 1
  systemctl --user "$action" "$UNIT" || return 1
  observed="$(observe)" || return 1
  attempts=0
  while [ "$expected:$observed" = active:starting ] && [ "$attempts" -lt 20 ]; do
    sleep 0.1
    observed="$(observe)" || return 1
    attempts=$((attempts + 1))
  done
  [ "$observed" = "$expected" ] || return 1
  [ "$(requested)" = "$state" ] || return 1
  publish_marker "$LEGACY_FILE" "$state" || return 1
  rm -f -- "$PENDING_FILE"
}

notify_state() {
  state="$1"
  notify-send "$(argvus_tr power keep_awake.title)" \
    "$(argvus_tr power "keep_awake.$state")" 2>/dev/null || true
}

case "${1:-status}" in
  status) requested ;;
  status-json)
    state="$(requested)" || exit 1
    observed="$(observe 2>/dev/null)" || observed=unavailable
    case "$state:$observed" in
      enabled:inactive|disabled:active) result=applied ;;
      *:unavailable) result=unavailable ;;
      *) result=pending ;;
    esac
    if [ "$result" = applied ] && { [ -e "$PENDING_FILE" ] ||
      { [ -f "$STATE_FILE" ] && [ "$(sed -n '1p' "$STATE_FILE")" != "$state" ]; }; }; then
      result=pending
    fi
    printf '{"requested":"%s","hypridle":"%s","state":"%s"}\n' "$state" "$observed" "$result"
    ;;
  on|off|toggle)
    mkdir -p "$STATE_DIR/internal"
    state="$(
    (
      flock -x 9 || exit 1
      case "$1" in
        on) state=enabled ;;
        off) state=disabled ;;
        toggle)
          current="$(requested)" || exit 1
          if [ "$current" = enabled ]; then state=disabled; else state=enabled; fi ;;
      esac
      if ! set_state "$state"; then
        printf '%s: %s (%s)\n' "$(argvus_tr session error.title)" "$(argvus_tr power keep_awake.title)" "$UNIT" >&2
        exit 1
      fi
      printf '%s\n' "$state"
    ) 9>"$STATE_DIR/internal/keep-awake.lock")" || {
      notify-send "$(argvus_tr power keep_awake.title)" "$(argvus_tr session error.title)" 2>/dev/null || true
      exit 1
    }
    # Notification errors do not change the result of an applied operation.
    notify_state "$state"
    printf '%s\n' "$state" ;;
  *) printf 'Usage: %s [status|status-json|on|off|toggle]\n' "$0" >&2; exit 2 ;;
esac
