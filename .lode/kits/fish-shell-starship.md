# fish-shell-starship

Mixin that ships the starship prompt binary and wires it into fish.

- Source: `fish-shell-starship/fish-shell-starship.yaml` + `fish-shell-starship/fish-shell-starship.dockerfile`
- Kind: mixin · DisplayName: `Starship prompt` · version 1.0.0
- Capabilities: `lifecycle@1` (two `files` entries, no hooks)
- Requires: `fish-shell`

## What it does

- **files** (UID 1000, `overwrite: false`):
  - `/home/agent/.config/fish/config.fish` — `starship init fish | source`
  - `/home/agent/.config/starship.toml` — minimal config (`add_newline = false`)
- **Dockerfile**: two-stage build shipping only the starship musl binary to
  `/usr/local/bin/starship`.

## Upstream artifact

| Tool | Version pin | Asset | Notes |
|---|---|---|---|
| starship | `STARSHIP_VERSION=1.27.0` | `starship-<arch>-unknown-linux-musl.tar.gz` | Release tag **has** the `v` prefix. Static musl binary, no runtime deps. |

`TARGETARCH` → upstream arch mapping (`amd64`→`x86_64`, `arm64`→`aarch64`), loud failure otherwise.

## Design decisions

- **No `network-policy` capability**: the binary downloads during image build; runtime makes no
  network calls.
- **Self-contained unit**: starship binary + its fish hook together; declares `requires: ["fish-shell"]` —
  fish itself comes from [fish-shell](fish-shell.md), the other fish config from
  [fish-shell-config](fish-shell-config.md).

## Invariants

- Bump pinned versions in the dockerfile `ARG`s when upgrading; config bodies stay inline in the
  manifest.
- `lifecycle files` content templates `${{ kit.args.* }}` but writes plain `$VAR` unchanged —
  config bodies are safe unless they contain `${{`.

Related: [fish-shell.md](fish-shell.md) · [fish-shell-config.md](fish-shell-config.md) · [extensible-shell.md](extensible-shell.md)
