# opencode

Mixin that installs the [OpenCode](https://opencode.ai) coding agent into any sandbox — the first
kit following the **agents-as-mixins** model: no dedicated workload, the agent arrives like any
other tool.

- Source: `opencode/opencode.yaml`
- Kind: mixin · DisplayName: `OpenCode agent` · version 1.0.0
- Args: `override_entrypoint` (default `"false"`, enum `true`/`false`) — opt-in entrypoint override ·
  `opencode_version` (default `"2.3.2"`) — mise version ref to install
- Capabilities: `network-policy@2`, `lifecycle@1`

## What it does

1. **network-policy@2** runtime allow: `opencode.ai`, `*.opencode.ai` (sandbox egress is
   default-deny).
2. **install (user 1000)**: `mise use -g "opencode@${{ kit.args.opencode_version }}"` — installed
   through [mise-en-place](mise-en-place.md)'s activated mise, on PATH via its shims.
3. **install (user 1000)**: when `override_entrypoint` is `true`, rewrites
   `/home/agent/entrypoint.sh` to `exec opencode` (`printf` + `chmod 0700`) — the same seam
   [fish-shell](fish-shell.md) takes, so the sandbox boots straight into the agent. The default
   `false` leaves the boot shell alone.

## Design decisions

- **Agent via mise, not a workload.** Replaces the removed `pi` workload approach: one generic
  [extensible-shell](extensible-shell.md) workload plus tool mixins compose a sandbox, instead of
  one workload kit per agent.
- **Depends on mise-en-place.** `mise use -g` needs the mise binary and its activation in the
  persistent env — declared as `requires: ["mise"]`, matching mise-en-place's `provides: ["mise"]`:
  composition fails closed without it, and the resolver orders the provider's overlay first.
- **Version pinned via the `opencode_version` arg** (default `2.3.2`): consumers pin or upgrade
  opencode per sandbox without editing the kit; bump the default to upgrade every composition.
- **Entrypoint override is opt-in (`override_entrypoint`, default `false`).** When a composition
  includes several kits carrying an `override_entrypoint` arg, only the one that should boot needs it
  set `true` — the rest keep the default and stay out of the way. opencode is usually a tool inside
  the shell, so it claims the seam only when asked (contrast [fish-shell](fish-shell.md), whose arg
  predates the opt-in convention and defaults `true`).

Related: [extensible-shell.md](extensible-shell.md) · [mise-en-place.md](mise-en-place.md) · [summary.md](summary.md)
