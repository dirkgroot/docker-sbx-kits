# fish-shell

Mixin that ships the fish binary and makes fish the `agent` user's login shell — and, when its
`auto_start` arg is set `true`, overrides the [extensible-shell](extensible-shell.md)
workload's entrypoint so the sandbox automatically starts fish.

- Source: `fish-shell/fish-shell.yaml` + `fish-shell/fish-shell.dockerfile`
- Kind: mixin · DisplayName: `Fish shell` · version 1.0.0
- Args: `auto_start` (default `"false"`, enum `true`/`false`) — opt-in gate on the entrypoint override
- Capabilities: `lifecycle@1` (four install hooks)
- Provides: `fish-shell` (unversioned — the pin lives in the dockerfile `ARG`, not the manifest, mirroring [mise-en-place](mise-en-place.md)'s rationale)

## What it does

1. **install (root)**: seeds `/etc/shells` with `/usr/local/bin/fish` (grep-guarded) and runs
   `usermod -s /usr/local/bin/fish agent`.
2. **install (user 1000)**: exports `SHELL=/usr/local/bin/fish` in `/etc/sandbox-persistent.sh`
   (grep-guarded) — this is how the opencode harness picks fish for its terminal and shell tools.
3. **install (user 1000)**: exports `PAGER=less` in `/etc/sandbox-persistent.sh` (grep-guarded) —
   the base image ships `/usr/bin/less` but no Debian `pager` alternatives shim, while git's Debian
   build defaults to `pager`, so interactive git fails with `unable to execute pager 'pager'`
   without it. The export reaches every shell (bash login, fish login, the harness terminal), not
   just fish sessions.
4. **install (user 1000)**: when `auto_start` is `true`, rewrites
   `/home/agent/entrypoint.sh` to `fish -l` (`printf` + `chmod 0700`) — so a sandbox composed as
   extensible-shell + fish-shell automatically starts fish. Running as the agent user, truncating the
   workload's file keeps it agent-owned; the `chmod` restores mode 0700 even if the file had to be
   created. The default `false` leaves the file alone and the boot shell stays with whatever kit
   writes it next — e.g. a tmux mixin that starts `tmux` (running fish inside).

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
- **The override is arg-gated (`auto_start`, default `false`) and hook-based — opt-in.**
  When several kits in a composition each carry an `auto_start` arg, only the one that
  should boot needs it set `true`; the rest keep the default and stay out of the way. Rewriting
  the entrypoint from an install hook is the one way every kit takes the composition seam: hooks run
  in dependency order, so a requirer (a tmux mixin, say) writes after fish-shell and its entrypoint
  wins, with no `files`-path collision to fear — lifecycle `files` must not touch the path (duplicate
  `files` paths are a composition error).

## Invariants

- Sole provider of the `fish-shell` capability name (`com.docker.kit/fish-shell`): fish-shell-config and
  fish-shell-starship declare `requires: ["fish-shell"]`, so this kit must be in the set for them to resolve.
- fish must ship as a single self-contained binary; if a future release stops embedding
  `share/fish`, the dockerfile must ship that directory too.
- The entrypoint overwrite stays an install hook running as `user: "1000"`, gated on
  `auto_start`: truncation keeps the workload's agent-owned file agent-owned, and
  `chmod 0700` restores the mode even if the hook had to create the file.
- Kits choose the boot shell by writing `/home/agent/entrypoint.sh` from install hooks only —
  never lifecycle `files` (duplicate `files` paths are a composition error); dependency order
  decides which write survives.
- `files` paths are absolute — the runtime does not expand `$HOME`.

Related: [fish-shell-config.md](fish-shell-config.md) · [fish-shell-starship.md](fish-shell-starship.md) · [extensible-shell.md](extensible-shell.md)
