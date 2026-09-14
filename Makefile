PREFIX ?= /usr
DESTDIR ?=
INSTALL ?= install
RM ?= rm -f

.DEFAULT_GOAL := help

.PHONY: help install uninstall validate release-archive clean

help:
	@echo "Available targets:"
	@echo "  make build"
	@echo "  make install"
	@echo "  make uninstall"
	@echo "  make validate"
	@echo "  make release-archive"

install:
	$(INSTALL) -dm755 "$(DESTDIR)$(PREFIX)/share/argvus/power"
	cp -a src/usr/share/argvus/power/. "$(DESTDIR)$(PREFIX)/share/argvus/power/"
	find "$(DESTDIR)$(PREFIX)/share/argvus/power/sh" -type f -name '*.sh' -exec chmod 755 {} \; 2>/dev/null || true
	$(INSTALL) -Dm644 LICENSE \
		"$(DESTDIR)$(PREFIX)/share/licenses/argvus-power/LICENSE"

uninstall:
	rm -rf "$(DESTDIR)$(PREFIX)/share/argvus/power"
	$(RM) "$(DESTDIR)$(PREFIX)/share/licenses/argvus-power/LICENSE"

validate:
	@set -eu; \
	scripts=$$(find src -type f -name '*.sh' | sort); \
	test -n "$$scripts"; \
	for script in $$scripts; do sh -n "$$script"; done; \
	if command -v shellcheck >/dev/null 2>&1; then \
		for script in $$scripts; do shellcheck -e SC1090 -e SC2034 "$$script"; done; \
	else \
		echo "shellcheck not found; skipped"; \
	fi
	@test -f src/usr/share/argvus/power/config/hypridle.conf
	@grep -q '/usr/share/argvus/power/sh/hypr-power-menu.sh --lock' src/usr/share/argvus/power/config/hypridle.conf
	@echo "argvus-power validation ok"

release-archive:
	mkdir -p .release
	git archive --format=tar.gz --prefix="argvus-power-$$(git rev-parse --short HEAD)/" \
		--output=".release/argvus-power-$$(git rev-parse --short HEAD).tar.gz" HEAD

.PHONY: build

build:
	@tools/build-local-package.sh

clean:
	rm -rf dist
	rm -f packaging/arch/*.zst packaging/arch/*.tar.gz
