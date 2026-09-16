#!/usr/bin/env sh

# shellcheck disable=SC1090,SC1091
ARGVUS_BOOTSTRAP="${ARGVUS_BOOTSTRAP:-${ARGVUS_SYSTEM_CONFIG:-/usr/share/argvus}/session/sh/bootstrap.sh}"
. "$ARGVUS_BOOTSTRAP"
# shellcheck disable=SC1091
. /usr/share/argvus/lib/i18n.sh

do_lock() {
  # Wallpaper paths belong to appearance and are not loaded by bootstrap.
  . "${ARGVUS_SYSTEM_CONFIG}/appearance/sh/hypr.sh"
  sh "$(paths_config lock/sh/hyprlock-theme.sh)" >/dev/null || return 1
  HYPRLOCK_PATH="$(
    sed -n \
      -e "s|^[[:space:]]*path[[:space:]]*=[[:space:]]*~|$HOME|p" \
      -e "s|^[[:space:]]*path[[:space:]]*=[[:space:]]*\\(/.*\\)|\\1|p" \
      "$(paths_config lock/config/hyprlock.conf)" |
      head -n1
  )"
  [ -n "$WALLPAPER_PATH" ] && [ -f "$WALLPAPER_PATH" ] || return 1
  [ -n "$HYPRLOCK_PATH" ] || return 1
  mkdir -p "${HYPRLOCK_PATH%/*}"
  if [ ! -f "$HYPRLOCK_PATH" ] || [ "$WALLPAPER_PATH" -nt "$HYPRLOCK_PATH" ]; then
    magick "$WALLPAPER_PATH" \
      -blur 0x2 \
      -fill black -colorize 20% \
      "$HYPRLOCK_PATH"
  fi
  if [ "$(sh "$(paths_config power/sh/lock-dpms-toggle.sh)" status)" = "enabled" ]; then
    (sleep 1; hyprctl dispatch 'hl.dsp.dpms({ action = "off" })') &
  fi
  exec hyprlock -c "$(paths_config lock/config/hyprlock.conf)"
}

do_logout() {
  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl eval 'hl.dispatch(hl.dsp.exit())' >/dev/null 2>&1 && exit 0
  fi

  if command -v loginctl >/dev/null 2>&1 && [ -n "${XDG_SESSION_ID:-}" ]; then
    loginctl terminate-session "$XDG_SESSION_ID" >/dev/null 2>&1 && exit 0
  fi

  if command -v pkill >/dev/null 2>&1; then
    pkill -TERM -u "$(id -u)" -x Hyprland >/dev/null 2>&1 && exit 0
    pkill -TERM -u "$(id -u)" -x hyprland >/dev/null 2>&1 && exit 0
  fi

  if command -v argvus-sessionctl >/dev/null 2>&1; then
    argvus-sessionctl stop >/dev/null 2>&1 || true
  fi

  if command -v hyprshutdown >/dev/null 2>&1; then
    exec hyprshutdown --no-fork
  fi

  exit 1
}

do_suspend() {
  systemctl suspend
}

do_reboot() {
  exec systemctl reboot
}

do_shutdown() {
  exec systemctl poweroff
}

# -- power-menu.sh --lock
# Also used for the keyboard shortcut Mod+Shift+l
# ------------------------------------------------------------------------------
case "${1:-}" in
  --lock)
    do_lock
    exit $?
    ;;
  --suspend)
    do_suspend
    exit $?
    ;;
  --logout)
    do_logout
    ;;
  --reboot)
    do_reboot
    ;;
  --shutdown|--poweroff)
    do_shutdown
    ;;
esac

# -- Translate -----------------------------------------------------------------
LOCK="$(argvus_tr power menu.lock)"
SUSPEND="$(argvus_tr power menu.suspend)"
LOGOUT="$(argvus_tr power menu.logout)"
REBOOT="$(argvus_tr power menu.reboot)"
SHUTDOWN="$(argvus_tr power menu.shutdown)"

# -- Menu -----------------------------------------------------------------
# Ensure we have the ARGVUS menu launcher.
if [ -z "$FINDER" ]; then
  if command -v rofi >/dev/null 2>&1; then
    FINDER=$(command -v rofi)
  else
    argvus_tr power menu.launcher_missing >&2
    exit 1
  fi
fi

# Use basename so different install paths still match
case "$(basename "$FINDER")" in
rofi)
  CHOICE=$(printf '%s\n' \
    "$LOCK" \
    "$SUSPEND" \
    "$LOGOUT" \
    "$REBOOT" \
    "$SHUTDOWN" |
    "$FINDER" -config "$(paths_config launcher/config/config.rasi)" -dmenu -p ">" \
    -theme-str 'window {width: 220px;} listview {lines: 5;}' -no-custom -i)
  ;;
*)
  argvus_tr power menu.unsupported_launcher "launcher=$FINDER" >&2
  exit 1
  ;;
esac

# ── Despatch ------------------------------------------------------------------
case "$CHOICE" in
"$LOCK")     do_lock ;;
"$SUSPEND")  do_suspend ;;
"$LOGOUT")   do_logout ;;
"$REBOOT")   do_reboot ;;
"$SHUTDOWN") do_shutdown ;;
esac
