# Terminology

Short entries: **term — meaning**.

- **Kit** — A reusable mixin package that customizes a Docker Sandbox; one directory per kit, manifest at `<kit>/<kit>.yaml`.
- **Mixin** — The `kind` of every kit in this repo: layers capabilities onto a sandbox instead of defining a base image.
- **Manifest** — A kit's YAML file, opening with the `# syntax=docker/sandbox-kit:3` header, then `schemaVersion: "3"`, `kind`, `displayName`.
- **Capability** — A typed unit of sandbox customization, id `com.docker.sandbox/<type>@<major>`, listed under `capabilities:`. Types in use: `agent-context@1`, `ssh-agent@1`, `lifecycle@1`, `network-policy@2`.
- **Kit arg** — A parameter declared under `args:` and supplied when the kit is used; referenced as `${{ kit.args.NAME }}`.
- **Lifecycle capability** — Runs shell commands: `install` hooks once at sandbox creation (before the agent launches, as root by default; `user: "1000"` demotes), `startup` hooks on every sandbox boot. Also carries `files`: per-user config written as UID 1000 at creation, after install hooks.
- **Network-policy capability** — Runtime egress allowlist; sandbox networking is default-deny, so tools that download need an explicit allow.
- **SSH-agent capability** — Injects an SSH agent with scoped uses: `sign: [git]`, `authenticate: [...]`, `phase: runtime`, `unrestricted: false`.
- **Agent-context capability** — Writes a text file (here `AGENTS.md`) into the agent's config directory; may be marked `optional: true`.
- **sbx** — The host CLI that assembles sandboxes from kits and manages policy, ports, secrets, and approvals.
- **AGENTS.md (repo root)** — The Lode Coding method; instructions for agents working in this repo, not project docs.
- **AGENTS.md (injected)** — The personal INTJ interaction rules written by the `agent-context` kit to `/home/agent/.config/opencode/AGENTS.md`.
- **Lode** — `.lode/`, the AI-owned structured memory of this project (indexed by [lode-map.md](lode-map.md)).
- **/etc/sandbox-persistent.sh** — Sandbox-wide env file sourced by every bash context (BASH_ENV, profile, bashrc); kits append env exports to it (e.g. `mise activate`, the fish `SHELL` export).
- **mise** — Polyglot dev-tool version manager (mise.jdx.dev) installed and activated by the `mise-en-place` kit.
- **fish** — Shell (fish 4.9.3) shipped as a standalone binary with embedded `share/fish` data by the `fish-starship` kit; set as the `agent` user's login shell.
- **starship** — Cross-shell prompt (starship 1.27.0) shipped as a static musl binary by the `fish-starship` kit; configured via `~/.config/starship.toml`.
