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
	$(INSTALL) -dm755 "$(DESTDIR)$(PREFIX)/share/argvus"
	cp -a src/. "$(DESTDIR)$(PREFIX)/share/argvus/"
	find "$(DESTDIR)$(PREFIX)/share/argvus/scripts" -type f -name '*.sh' -exec chmod 755 {} \; 2>/dev/null || true
	$(INSTALL) -Dm644 LICENSE \
		"$(DESTDIR)$(PREFIX)/share/licenses/argvus-power/LICENSE"

uninstall:
	$(RM) "$(DESTDIR)$(PREFIX)/share/argvus/scripts/apps/hypr-power-menu.sh"
	$(RM) "$(DESTDIR)$(PREFIX)/share/argvus/scripts/argvus/idle-timeout.sh"
	$(RM) "$(DESTDIR)$(PREFIX)/share/argvus/scripts/argvus/lock-dpms-toggle.sh"
	$(RM) "$(DESTDIR)$(PREFIX)/share/argvus/hypr/hypridle.conf"
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
	@test -f src/hypr/hypridle.conf
	@grep -q '/usr/share/argvus/scripts/apps/hypr-power-menu.sh --lock' src/hypr/hypridle.conf
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
