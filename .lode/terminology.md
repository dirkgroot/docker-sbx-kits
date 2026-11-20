# Terminology

Short entries: **term — meaning**.

- **Kit** — A reusable package that customizes a Docker Sandbox; one directory per kit, manifest at `<kit>/<kit>.yaml`. Kinds: `mixin` (overlay layer) and `workload` (base image the host boots).
- **Workload** — The `kind` of the base kit a sandbox boots from; a sandbox takes exactly one. This repo has exactly one: `extensible-shell`.
- **Base tools** — Generic tools every sandbox should have, installed in the workload's Dockerfile via `apt-get` at build time (vim; jq already ships in the platform floor at 1.8.2, and trixie's `yq` package is the wrong implementation). Optional and specialized tools are mixins installed via mise instead. See [kits/extensible-shell.md](kits/extensible-shell.md).
- **Mixin** — A `kind` of kit that layers capabilities onto a sandbox instead of defining a base image. Agents and tools are mixins in this repo, not workloads.
- **Manifest** — A kit's YAML file, opening with the `# syntax=docker/sandbox-kit:3` header, then the `# yaml-language-server:` modeline pointing at `docker/sandbox-kit-spec`'s `schema/kit.schema.json` (editor validation/completion), then `schemaVersion: "3"`, `kind`, `displayName`, `version`.
- **Capability** — A typed unit of sandbox customization, id `com.docker.sandbox/<type>@<major>`, listed under `capabilities:`. Types in use: `agent-context@1`, `ssh-agent@1`, `lifecycle@1`, `network-policy@2`.
- **Kit arg** — A parameter declared under `args:` and supplied when the kit is used; referenced as `${{ kit.args.NAME }}`.
- **`provides`** — Kit-to-kit capability offer: `name` or `name@version`; nothing is provided implicitly. Bare names normalize to `com.docker.kit/`, and a provide is named after the kit that declares it (`mise-en-place` ≡ `com.docker.kit/mise-en-place`, `fish-shell` ≡ `com.docker.kit/fish-shell`). Distinct from `capabilities:`, which asks the host. mise-en-place provides `mise-en-place`; fish-shell provides `fish-shell`.
- **`requires`** — Kit-to-kit constraint checked against the resolved set (closed-set check, no registry fetch): composition fails closed when no provider in the set satisfies it, never pulls a kit in; the resolver orders providers before requirers. Unversioned provides satisfy only unconstrained requires. opencode requires `mise-en-place`; fish-shell-config and fish-shell-starship require `fish-shell`.
- **Lifecycle capability** — Runs shell commands: `install` hooks once at sandbox creation (before the agent launches, as root by default; `user: "1000"` demotes), `startup` hooks on every sandbox boot. Also carries `files`: per-user config written as UID 1000 at creation, after install hooks.
- **Network-policy capability** — Phase-scoped egress policy (`@2`): install is open while install hooks run (the `install` key only narrows it), runtime is default-deny and governed by `runtime.allow`. Only session-time downloads need an explicit allow (opencode → `opencode.ai`; mise-en-place → `mise*.jdx.dev` for workspace tools). Build-time and install-hook downloads (fish, starship, mise-installed tools) need none.
- **SSH-agent capability** — Injects an SSH agent with scoped uses: `sign: [git]`, `authenticate: [...]`, `phase: runtime`, `unrestricted: false`.
- **Agent-context capability** — Writes a text file (here `AGENTS.md`) into the agent's config directory; may be marked `optional: true`.
- **sbx@1 capability** — The workload-only agent-sandbox declaration; no config. Tells the host to launch the agent instead of the image's entrypoint as PID 1. Unused by extensible-shell, which boots its plain entrypoint.
- **Entrypoint override** — The composition seam: extensible-shell ships `/home/agent/entrypoint.sh` (`bash -l`, agent-owned, mode 0700) and a mixin rewrites it from an install hook (as `user: "1000"`) to choose the boot shell — the one way every kit takes the seam. Install hooks run in dependency order, so requirers write after providers and win; lifecycle `files` must not touch the path (duplicate `files` paths are a composition error). The write is gated behind an `auto_start` arg, **opt-in by convention** (default `false`): a
composition sets it on exactly the one kit that should boot. fish-shell writes `fish -l`; opencode
writes `exec opencode`.
- **Secret injection** — Docker Sandbox's mechanism for supplying credentials (e.g. a fine-grained GitHub/GitLab personal access token) at runtime; the chosen auth path for remote Git, replacing SSH `authenticate` scopes.
- **sbx** — The host CLI that assembles sandboxes from kits and manages policy, ports, secrets, and approvals.
- **AGENTS.md (repo root)** — The Lode Coding method; instructions for agents working in this repo, not project docs.
- **AGENTS.md (injected)** — The personal INTJ interaction rules written by the `agent-context` kit to `/home/agent/.config/opencode/AGENTS.md`.
- **Lode** — `.lode/`, the AI-owned structured memory of this project (indexed by [lode-map.md](lode-map.md)).
- **/etc/sandbox-persistent.sh** — Sandbox-wide env file sourced by every bash context (BASH_ENV, profile, bashrc); kits append env exports to it (e.g. `mise activate`, the fish `SHELL` and `PAGER=less` exports).
- **mise** — Polyglot dev-tool version manager (mise.jdx.dev) installed and activated by the `mise-en-place` kit; the preferred installer for agents and tools.
- **opencode** — The OpenCode coding agent (opencode.ai), installed as a mixin via `mise use -g` at
  the version given by its `opencode_version` arg (default `2.3.2`); can boot the sandbox via its
  opt-in `auto_start` arg. See [kits/opencode.md](kits/opencode.md).
- **fish** — Shell (fish 4.9.3) shipped as a standalone binary with embedded `share/fish` data by the `fish-shell` kit; login shell of the `agent` user and — when its `auto_start` arg is set `true` — the boot shell via the entrypoint override. Config comes from `fish-shell-config`.
- **starship** — Cross-shell prompt (starship 1.27.0) shipped as a static musl binary by the `fish-shell-starship` kit; configured via `~/.config/starship.toml`.
