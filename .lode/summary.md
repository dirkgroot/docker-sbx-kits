# Summary

**sbx-kits** is a personal collection of Docker Sandbox kits for the `sbx` CLI, organized around one
principle: a single generic **workload** — `extensible-shell`, a bare shell sandbox on
`dhi.io/sbx-templates:shell-docker` whose `/home/agent/entrypoint.sh` is deliberately overridable —
plus small focused **mixins** that compose on top. Agents are mixins too, installed via `mise`
rather than dedicated workloads: `opencode` brings the OpenCode coding agent (`mise use -g
opencode@2.2.7`) with an `opencode.ai` egress allow. Every kit is a directory with a
`schemaVersion: 3` YAML manifest (header `# syntax=docker/sandbox-kit:3`) declaring typed
`com.docker.sandbox/*` capabilities and the args they consume. The mixins: `agent-context` injects a
personal `AGENTS.md`; `git-identity-sign` sets Git identity with SSH commit **signing** only —
remote authentication is delegated to Docker Sandbox secret injection with fine-grained tokens, so
the ssh-agent no longer authenticates; `mise-en-place` installs and activates the `mise` tool
manager (egress `mise*.jdx.dev`); the old monolithic `fish-starship` kit is split for composability
into `fish-shell` (fish binary + login shell + entrypoint override to `fish -l`),
`fish-shell-config` (conf.d drop-ins), and `fish-shell-starship` (starship binary + fish init). The
repo-root `AGENTS.md` is not project documentation — it is the **Lode Coding** method governing
every agent working here, including keeping this `.lode/` accurate. The folder is a git repository
(branch `main`, no remote configured).

Related: [lode-map.md](lode-map.md) · [kits/summary.md](kits/summary.md)
