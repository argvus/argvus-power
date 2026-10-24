# argvus-power

<div align="center">

[![CI](https://github.com/argvus/argvus-power/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/argvus/argvus-power/actions/workflows/ci.yml)
[![License](https://img.shields.io/github/license/argvus/argvus-power)](./LICENSE)
[![Language: Shell](https://img.shields.io/badge/Shell-POSIX-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)
[![Platform: Arch Linux | Wayland](https://img.shields.io/badge/platform-Arch%20Linux%20%7C%20Wayland-1793D1?logo=archlinux&logoColor=white)](https://archlinux.org/)
[![Pull requests](https://img.shields.io/github/issues-pr/argvus/argvus-power)](https://github.com/argvus/argvus-power/pulls)
[![Issues](https://img.shields.io/github/issues/argvus/argvus-power)](https://github.com/argvus/argvus-power/issues)
[![Last commit](https://img.shields.io/github/last-commit/argvus/argvus-power)](https://github.com/argvus/argvus-power/commits/main)
[![Docs](https://img.shields.io/badge/docs-project-blue)](./docs/)

</div>

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
makepkg -p packaging/arch/remote/PKGBUILD --printsrcinfo
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
- [CONTRIBUTING.md](https://github.com/argvus/.github/blob/main/CONTRIBUTING.md) — contribution workflow
- [SECURITY.md](https://github.com/argvus/.github/blob/main/SECURITY.md) — private vulnerability reports
- [Code of Conduct](https://github.com/argvus/.github/blob/main/policies/CODE_OF_CONDUCT.md) — community standards
- [AI usage policy](https://github.com/argvus/.github/blob/main/policies/IA_USAGE.md) — rules for AI-assisted contributions

## License

SPDX: `GPL-3.0-only`. See [LICENSE](LICENSE).
