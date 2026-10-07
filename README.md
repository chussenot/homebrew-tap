# homebrew-tap

Homebrew formulae for [chussenot](https://github.com/chussenot)'s command-line tools.

```sh
brew install chussenot/tap/jud
```

| Formula | What it is | Platforms |
|---|---|---|
| [`jud`](Formula/jud.rb) | Evaluates JSON against a `.jud` rubric with a calibrated System One model: `cat event.json \| jud triage.jud`. From [chussenot/judgment](https://github.com/chussenot/judgment). | Apple silicon, Linux x86-64 and arm64 |

## How a formula here is built

Nothing is compiled by Homebrew. Each formula installs the tarballs of a
GitHub release: binaries built on native runners, run before they were
packaged, with a `SHA256SUMS` file and a build-provenance attestation
(`gh attestation verify <tarball> --repo chussenot/judgment`). The formula's
checksums are those of the release, and the formula is rendered and
committed here by the upstream release workflow on each release
(`scripts/homebrew-formula.sh` in that repository), so a version here is a
version there. Shell completions (bash, zsh, fish) are generated from the
binary at install time.

Intel macOS has no release tarball, so the formula refuses it with a message;
an Intel Mac installs from crates.io: `cargo install judgment --features cli`.

## Trust

Since Homebrew 6.0 a third-party tap is not trusted by default: its formulae
are not even read until you say so. The fully qualified install above trusts
the one formula it names and nothing else, which is the recommended form. To
install by short name instead:

```sh
brew tap chussenot/tap
brew trust --formula chussenot/tap/jud
brew install jud
```

`brew trust` lists what is trusted, `brew untrust` revokes it.

## Checks

On every push and pull request, CI audits the tap (`brew audit --strict`),
installs each formula from the real release tarballs on macOS (Apple silicon)
and Linux, runs its `test` block and checks that the completions were
installed.
