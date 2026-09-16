# argvus-power

Power, shutdown, reboot, suspend, idle timeout and DPMS controls for the
ARGVUS desktop.

## Build and install

On Arch Linux or a compatible distribution:

```sh
sudo pacman -S --needed base-devel git shellcheck
make validate
make build
make install
```

`make build` creates a deterministic source archive in `build/artifacts/` and
the package in `build/dist/`. For metadata only:

```sh
make validate
makepkg -p packaging/arch/ci/PKGBUILD --printsrcinfo
```

## Package payload

This package owns the files below:

```text
/usr/share/argvus/power/config/hypridle.conf
/usr/share/argvus/power/sh/hypr-power-menu.sh
/usr/share/argvus/power/sh/idle-timeout.sh
/usr/share/argvus/power/sh/lock-dpms-toggle.sh
```

The lock screen theme remains owned by `argvus-lock`; this package invokes it
when available. `power-profiles-daemon` and ImageMagick remain optional.

## Documentation

- [DEVELOPMENT.md](DEVELOPMENT.md) — layout, checks and releases
- [CONTRIBUTING.md](CONTRIBUTING.md) — contribution workflow
- [SECURITY.md](SECURITY.md) — private vulnerability reports

## License

SPDX: `GPL-3.0-only`. See [LICENSE](LICENSE).
