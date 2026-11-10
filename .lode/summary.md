# Summary

**sbx-kits** is a personal collection of Docker Sandbox kits: three mixins (`agent-context`,
`git-identity-sign`, `mise-en-place`) that customize sandboxes built with the `sbx` CLI. Each kit is a
directory containing a `schemaVersion: 3` YAML manifest (header `# syntax=docker/sandbox-kit:3`,
`kind: mixin`) that declares typed `com.docker.sandbox/*` capabilities and the args they consume. The kits
cover: injecting a personal `AGENTS.md` into the agent config directory, configuring Git identity with SSH
commit signing, and installing/activating the `mise` tool manager (staged via a two-stage Dockerfile). The repo-root `AGENTS.md` is not project documentation — it
is the **Lode Coding** method governing every agent working here, including keeping this `.lode/`
accurate. The folder is a git repository (branch `main`, no remote configured).

Related: [lode-map.md](lode-map.md) · [kits/summary.md](kits/summary.md)
