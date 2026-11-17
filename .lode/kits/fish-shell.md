# fish-shell

Mixin that ships the fish binary and makes fish the `agent` user's login shell — including
overriding the [extensible-shell](extensible-shell.md) workload's entrypoint so the sandbox boots
straight into fish.

- Source: `fish-shell/fish-shell.yaml` + `fish-shell/fish-shell.dockerfile`
- Kind: mixin · DisplayName: `Fish shell` · version 1.0.0
- Capabilities: `lifecycle@1` (two install hooks + one `files` entry)
- Provides: `fish` (unversioned — the pin lives in the dockerfile `ARG`, not the manifest, mirroring [mise-en-place](mise-en-place.md)'s rationale)

## What it does

1. **install (root)**: seeds `/etc/shells` with `/usr/local/bin/fish` (grep-guarded) and runs
   `usermod -s /usr/local/bin/fish agent`.
2. **install (user 1000)**: exports `SHELL=/usr/local/bin/fish` in `/etc/sandbox-persistent.sh`
   (grep-guarded) — this is how the opencode harness picks fish for its terminal and shell tools.
3. **files**: `/home/agent/entrypoint.sh` (`fish -l`, `overwrite: true`) — replaces the workload's
   bash entrypoint, so a sandbox composed as extensible-shell + fish-shell boots into fish.

Binary only: fish *configuration* lives in [fish-shell-config](fish-shell-config.md), starship in
[fish-shell-starship](fish-shell-starship.md).

## Upstream artifact

| Tool | Version pin | Asset | Notes |
|---|---|---|---|
| fish | `FISH_VERSION=4.9.3` | `fish-<v>-linux-<arch>.tar.xz` | Release tag has **no** `v` prefix. Single self-contained binary: fish 4 embeds its `share/fish` data (`functions fish_prompt` → `embedded:functions/…`). |

The dockerfile maps Docker's `TARGETARCH` (`amd64`/`arm64`) to upstream arch names
(`x86_64`/`aarch64`) and fails loudly on anything else. Two-stage build ending `FROM scratch`
ships only the binary (same pattern as [mise-en-place](mise-en-place.md)).

## Design decisions

- **No `network-policy` capability.** The binary downloads during the Dockerfile's image build;
  install hooks and runtime make no network calls (unlike mise, which fetches at runtime — see
  [mise-en-place](mise-en-place.md)).
- **Default shell via `usermod -s` in a root install hook — never `sudo`, never `chsh`** — see
  [practices](../practices.md) for the PAM rationale.
- **Entrypoint override instead of bash handoff.** With a self-owned workload, replacing
  `entrypoint.sh` is the lever for choosing the boot shell; the old guarded `exec fish` in
  `~/.bash_profile` trick is retired.

## Invariants

- Sole provider of the `fish` capability name (`com.docker.kit/fish`): fish-shell-config and
  fish-shell-starship declare `requires: ["fish"]`, so this kit must be in the set for them to resolve.
- fish must ship as a single self-contained binary; if a future release stops embedding
  `share/fish`, the dockerfile must ship that directory too.
- The `entrypoint.sh` files entry must keep `overwrite: true`, or the workload's bash entrypoint
  wins.
- `files` paths are absolute — the runtime does not expand `$HOME`.

Related: [fish-shell-config.md](fish-shell-config.md) · [fish-shell-starship.md](fish-shell-starship.md) · [extensible-shell.md](extensible-shell.md)
