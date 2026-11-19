# Summary

**sbx-kits** is a personal collection of Docker Sandbox kits for the `sbx` CLI, organized around one
principle: a single generic **workload** — `extensible-shell`, a bare shell sandbox on
`dhi.io/sbx-templates:shell-docker` whose `/home/agent/entrypoint.sh` is deliberately overridable —
plus small focused **mixins** that compose on top. Agents are mixins too, installed via `mise`
rather than dedicated workloads: `opencode` brings the OpenCode coding agent via mise (version
pinned by its `opencode_version` arg, default 2.3.2) with an `opencode.ai` egress allow and an
opt-in `auto_start` that starts the agent automatically. Every kit is a directory with a
`schemaVersion: 3` YAML manifest (header `# syntax=docker/sandbox-kit:3`) declaring typed
`com.docker.sandbox/*` capabilities and the args they consume. The mixins: `agent-context` injects a
personal `AGENTS.md`; `git-identity-sign` sets Git identity with SSH commit **signing** only —
remote authentication is delegated to Docker Sandbox secret injection with fine-grained tokens, so
the ssh-agent no longer authenticates; `mise-en-place` installs and activates the `mise` tool
manager (egress `mise*.jdx.dev`); the old monolithic `fish-starship` kit is split for composability
into `fish-shell` (fish binary + login shell + `fish -l` autostart gated by `auto_start`),
`fish-shell-config` (conf.d drop-ins), and `fish-shell-starship` (starship binary + fish init). The
repo-root `AGENTS.md` is not project documentation — it is the **Lode Coding** method governing
every agent working here, including keeping this `.lode/` accurate. The folder is a git repository
(branch `main`, no remote configured).

Related: [lode-map.md](lode-map.md) · [kits/summary.md](kits/summary.md)
