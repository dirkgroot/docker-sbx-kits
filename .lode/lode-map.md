# Lode Map

Index of all lode files. Start here in every new session; read [summary.md](summary.md) and
[terminology.md](terminology.md) next.

## Meta

- [summary.md](summary.md) — one-paragraph living snapshot of the project.
- [terminology.md](terminology.md) — domain language: kits, kinds, capabilities, args, sbx, entrypoint override.
- [practices.md](practices.md) — kit-authoring patterns and lode upkeep rules.
- [README.md](../README.md) — public-facing project overview for humans: the "ingredients" idea, the design (workload vs mixins, entrypoint seam, provides/requires, security posture), and the kit catalog.

## kits/ — one file per kit

- [kits/summary.md](kits/summary.md) — kit catalog (workload vs mixins), the compose-don't-specialize model, and how a sandbox assembles.
- [kits/extensible-shell.md](kits/extensible-shell.md) — the baseline workload: bare shell sandbox with overridable entrypoint.
- [kits/agent-context.md](kits/agent-context.md) — injects the personal INTJ `AGENTS.md`.
- [kits/git-identity-sign.md](kits/git-identity-sign.md) — Git identity + SSH commit signing (sign-only; auth via secret injection).
- [kits/mise-en-place.md](kits/mise-en-place.md) — installs and activates the `mise` tool manager.
- [kits/fish-shell.md](kits/fish-shell.md) — fish binary, login shell, and the `auto_start`-gated fish autostart.
- [kits/fish-shell-config.md](kits/fish-shell-config.md) — fish conf.d configuration drop-ins.
- [kits/fish-shell-starship.md](kits/fish-shell-starship.md) — starship binary + fish init/toml.
- [kits/opencode.md](kits/opencode.md) — OpenCode coding agent installed via mise (agents-as-mixins).

## plans/

- [plans/roadmap.md](plans/roadmap.md) — open TODOs and known inconsistencies.

## tmp/

- `tmp/` — git-ignored session scraps (not indexed).
