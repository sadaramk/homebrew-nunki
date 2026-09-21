# homebrew-nunki

Homebrew tap for [nunki](https://github.com/sadaramk/nunki) — architecture
documentation generated from source code, with every claim linked to the line it
came from and verified against the commit.

```sh
brew install sadaramk/nunki/nunki
```

The formula installs the prebuilt binary published with each release, so there
is nothing to compile. Homebrew fetches over curl, which means macOS does not
quarantine the download — unlike an archive downloaded through a browser, which
Gatekeeper refuses to run because the binary is not notarized.

Formulae here are updated automatically by the release workflow in the main
repository.
