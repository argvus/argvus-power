# argvus-power

Power menu, shutdown/reboot/suspend integration, idle timeout and DPMS controls for ARGVUS.

Read the ecosystem plan first:

```text
/home/boss/Projects/github/organizations/argvus/argvus-session/tmp/AGENT_PLAN.md
```

Avoid persistent background processes unless they are supervised by the ARGVUS session manager.

## Ownership

This package owns:

- `/usr/share/argvus/scripts/apps/hypr-power-menu.sh`
- `/usr/share/argvus/scripts/argvus/idle-timeout.sh`
- `/usr/share/argvus/scripts/argvus/lock-dpms-toggle.sh`
- `/usr/share/argvus/hypr/hypridle.conf`

The lock screen theme/config is owned by `argvus-lock`. The power menu calls
`hyprlock-theme.sh` when it is available, then invokes `hyprlock` and applies
the DPMS-on-lock policy managed by this package.

Idle timeout changes update the mutable Hypridle config copy and reload the
runtime through:

```sh
argvus-sessionctl restart hypridle
```

## Commands

```sh
sh /usr/share/argvus/scripts/apps/hypr-power-menu.sh
sh /usr/share/argvus/scripts/apps/hypr-power-menu.sh --lock
sh /usr/share/argvus/scripts/apps/hypr-power-menu.sh --suspend
sh /usr/share/argvus/scripts/apps/hypr-power-menu.sh --logout
sh /usr/share/argvus/scripts/apps/hypr-power-menu.sh --reboot
sh /usr/share/argvus/scripts/apps/hypr-power-menu.sh --shutdown

sh /usr/share/argvus/scripts/argvus/idle-timeout.sh status
sh /usr/share/argvus/scripts/argvus/idle-timeout.sh 300

sh /usr/share/argvus/scripts/argvus/lock-dpms-toggle.sh status
sh /usr/share/argvus/scripts/argvus/lock-dpms-toggle.sh toggle
```

## Installation

```sh
make install
```

Use `DESTDIR` for packaging:

```sh
make DESTDIR="$pkgdir" PREFIX=/usr install
```

## Validation

```sh
make validate
make DESTDIR=/tmp/argvus-power-dest PREFIX=/usr install
makepkg --printsrcinfo
git diff --check
```

`power-profiles-daemon` remains optional. Existing Waybar and Quickshell power
profile controls use `powerprofilesctl` directly. `rofi` is the preferred menu
launcher, `wofi` is supported as a fallback, and ImageMagick enables the blurred
lock wallpaper generation.
