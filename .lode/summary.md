# Summary

**sbx-kits** is a personal collection of Docker Sandbox kits: four mixins (`agent-context`,
`git-identity-sign`, `mise-en-place`, `fish-starship`) and one workload (`pi`) that customize sandboxes built with the `sbx` CLI. Each kit is a
directory containing a `schemaVersion: 3` YAML manifest (header `# syntax=docker/sandbox-kit:3`) that declares typed
`com.docker.sandbox/*` capabilities and the args they consume. The mixins cover: injecting a personal
`AGENTS.md` into the agent config directory, configuring Git identity with SSH commit signing,
installing/activating the `mise` tool manager (staged via a two-stage Dockerfile), and installing the fish shell
+ starship prompt with fish set as the `agent` user's login shell. The `pi` workload makes Pi (pi.dev) the agent
the host launches — interactively inside a persistent tmux session via a `pi-launch` tty-gated
wrapper — with pinned releases, an optional GitHub credential (provider API domains stay on the
egress allowlist, so more providers are one `credential@1` capability each), and an MCP-gateway seed.
The repo-root `AGENTS.md` is not project documentation — it
is the **Lode Coding** method governing every agent working here, including keeping this `.lode/`
accurate. The folder is a git repository (branch `main`, no remote configured).

Related: [lode-map.md](lode-map.md) · [kits/summary.md](kits/summary.md)
