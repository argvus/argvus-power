# Development

## Project layout

```text
packaging/arch/remote/       release PKGBUILD
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

Set the release tag to the unchanged `pkgver` in `packaging/arch/remote/PKGBUILD`.
The release workflow builds and signs the package for the ARGVUS repository.

## Keep Awake consistency

The persistent request is `/power/keep_awake`. Session startup prefers that
value, with `data/power/.keep-awake` and then `data/.keep-awake` as compatibility
inputs when the preference is absent. The two marker files are updated by a
successful operation. The older marker is retained for old readers.

All packaged control surfaces use `keep-awake.sh`. Mutations hold an advisory
lock, save the request and projected marker, then start or stop Hypridle and
verify its observed state. A failed or interrupted mutation may leave a saved
request and a pending record. Retry with explicit `on` or `off` to complete it.
`status` reports the request and `status-json` also reports the observed unit
and application state. Unit inactivity only supports the requested enabled
state when the unit is loaded. The query does not attest to other idle or
suspension policies.

Run the isolated tests with `python3 -B tests/test_keep_awake.py`.
