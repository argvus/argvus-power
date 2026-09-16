# Development

## Project layout

```text
packaging/arch/ci/       release PKGBUILD
packaging/arch/local/   working-tree PKGBUILD
packaging/arch/common/  shared packaging functions
src/                    installed package payload
tools/sh/               build and validation scripts
build/                  ignored build outputs
```

## Local checks

```sh
make validate
make lint
make build
```

The local builder creates the source archive and computes its checksum in a
temporary PKGBUILD. Repository PKGBUILDs intentionally keep `sha256sums=()`;
release CI updates the checksum before building the tagged source archive.

## Release

Set the release tag to the unchanged `pkgver` in `packaging/arch/ci/PKGBUILD`.
The release workflow builds and signs the package for the ARGVUS repository.
