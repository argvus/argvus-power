# Arch packaging layout

`local/PKGBUILD` builds the working tree through `make build`; `ci/PKGBUILD`
builds the tagged GitHub source archive. Their package metadata and payload
behavior remain equivalent, while their source definitions differ.

The shared `common/functions.sh` normalizes the source directory and installs
the complete `src/usr/share/argvus` payload with the project-specific modes.
