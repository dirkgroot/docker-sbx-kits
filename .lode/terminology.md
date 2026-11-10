# Terminology

Short entries: **term — meaning**.

- **Kit** — A reusable mixin package that customizes a Docker Sandbox; one directory per kit, manifest at `<kit>/<kit>.yaml`.
- **Mixin** — The `kind` of every kit in this repo: layers capabilities onto a sandbox instead of defining a base image.
- **Manifest** — A kit's YAML file, opening with the `# syntax=docker/sandbox-kit:3` header, then `schemaVersion: "3"`, `kind`, `displayName`.
- **Capability** — A typed unit of sandbox customization, id `com.docker.sandbox/<type>@<major>`, listed under `capabilities:`. Types in use: `agent-context@1`, `port@1`, `ssh-agent@1`, `lifecycle@1`, `network-policy@2`.
- **Kit arg** — A parameter declared under `args:` and supplied when the kit is used; referenced as `${{ kit.args.NAME }}`.
- **Lifecycle capability** — Runs shell commands at `install` (image build) and `startup` (every sandbox boot).
- **Network-policy capability** — Runtime egress allowlist; sandbox networking is default-deny, so tools that download need an explicit allow.
- **SSH-agent capability** — Injects an SSH agent with scoped uses: `sign: [git]`, `authenticate: [...]`, `phase: runtime`, `unrestricted: false`.
- **Agent-context capability** — Writes a text file (here `AGENTS.md`) into the agent's config directory; may be marked `optional: true`.
- **Port capability** — Publishes a sandbox port to the host (`container: <port>`, `transport: tcp`).
- **sbx** — The host CLI that assembles sandboxes from kits and manages policy, ports, secrets, and approvals.
- **AGENTS.md (repo root)** — The Lode Coding method; instructions for agents working in this repo, not project docs.
- **AGENTS.md (injected)** — The personal INTJ interaction rules written by the `agent-context` kit to `/home/agent/.config/opencode/AGENTS.md`.
- **Lode** — `.lode/`, the AI-owned structured memory of this project (indexed by [lode-map.md](lode-map.md)).
- **mise** — Polyglot dev-tool version manager (mise.jdx.dev) installed and activated by the `mise-en-place` kit.
