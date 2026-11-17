# Terminology

Short entries: **term — meaning**.

- **Kit** — A reusable package that customizes a Docker Sandbox; one directory per kit, manifest at `<kit>/<kit>.yaml`. Kinds: `mixin` (overlay layer) and `workload` (base image the host boots).
- **Workload** — The `kind` of the base kit a sandbox boots from; a sandbox takes exactly one. This repo has exactly one: `extensible-shell`.
- **Mixin** — A `kind` of kit that layers capabilities onto a sandbox instead of defining a base image. Agents and tools are mixins in this repo, not workloads.
- **Manifest** — A kit's YAML file, opening with the `# syntax=docker/sandbox-kit:3` header, then the `# yaml-language-server:` modeline pointing at `docker/sandbox-kit-spec`'s `schema/kit.schema.json` (editor validation/completion), then `schemaVersion: "3"`, `kind`, `version`, `displayName`.
- **Capability** — A typed unit of sandbox customization, id `com.docker.sandbox/<type>@<major>`, listed under `capabilities:`. Types in use: `agent-context@1`, `ssh-agent@1`, `lifecycle@1`, `network-policy@2`.
- **Kit arg** — A parameter declared under `args:` and supplied when the kit is used; referenced as `${{ kit.args.NAME }}`.
- **Lifecycle capability** — Runs shell commands: `install` hooks once at sandbox creation (before the agent launches, as root by default; `user: "1000"` demotes), `startup` hooks on every sandbox boot. Also carries `files`: per-user config written as UID 1000 at creation, after install hooks.
- **Network-policy capability** — Runtime egress allowlist; sandbox networking is default-deny, so tools that download need an explicit allow.
- **SSH-agent capability** — Injects an SSH agent with scoped uses: `sign: [git]`, `authenticate: [...]`, `phase: runtime`, `unrestricted: false`.
- **Agent-context capability** — Writes a text file (here `AGENTS.md`) into the agent's config directory; may be marked `optional: true`.
- **sbx@1 capability** — The workload-only agent-sandbox declaration; no config. Tells the host to launch the agent instead of the image's entrypoint as PID 1. Unused by extensible-shell, which boots its plain entrypoint.
- **Entrypoint override** — The composition seam: extensible-shell ships `/home/agent/entrypoint.sh` (`bash -l`) and a mixin replaces it via lifecycle `files` with `overwrite: true` to choose the boot shell (fish-shell → `fish -l`).
- **Secret injection** — Docker Sandbox's mechanism for supplying credentials (e.g. a fine-grained GitHub/GitLab personal access token) at runtime; the chosen auth path for remote Git, replacing SSH `authenticate` scopes.
- **sbx** — The host CLI that assembles sandboxes from kits and manages policy, ports, secrets, and approvals.
- **AGENTS.md (repo root)** — The Lode Coding method; instructions for agents working in this repo, not project docs.
- **AGENTS.md (injected)** — The personal INTJ interaction rules written by the `agent-context` kit to `/home/agent/.config/opencode/AGENTS.md`.
- **Lode** — `.lode/`, the AI-owned structured memory of this project (indexed by [lode-map.md](lode-map.md)).
- **/etc/sandbox-persistent.sh** — Sandbox-wide env file sourced by every bash context (BASH_ENV, profile, bashrc); kits append env exports to it (e.g. `mise activate`, the fish `SHELL` export).
- **mise** — Polyglot dev-tool version manager (mise.jdx.dev) installed and activated by the `mise-en-place` kit; the preferred installer for agents and tools.
- **opencode** — The OpenCode coding agent (opencode.ai), installed as a mixin via `mise use -g opencode@2.2.7`. See [kits/opencode.md](kits/opencode.md).
- **fish** — Shell (fish 4.9.3) shipped as a standalone binary with embedded `share/fish` data by the `fish-shell` kit; login shell of the `agent` user and, via the entrypoint override, the boot shell. Config comes from `fish-shell-config`.
- **starship** — Cross-shell prompt (starship 1.27.0) shipped as a static musl binary by the `fish-shell-starship` kit; configured via `~/.config/starship.toml`.
