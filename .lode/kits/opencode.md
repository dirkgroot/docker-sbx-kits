# opencode

Mixin that installs the [OpenCode](https://opencode.ai) coding agent into any sandbox — the first
kit following the **agents-as-mixins** model: no dedicated workload, the agent arrives like any
other tool.

- Source: `opencode/opencode.yaml`
- Kind: mixin · DisplayName: `OpenCode agent` · version 1.0.0
- Capabilities: `network-policy@2`, `lifecycle@1`

## What it does

1. **network-policy@2** runtime allow: `opencode.ai`, `*.opencode.ai` (sandbox egress is
   default-deny).
2. **install (user 1000)**: `mise use -g opencode@2.2.7` — pinned, installed through
   [mise-en-place](mise-en-place.md)'s activated mise, on PATH via its shims.

## Design decisions

- **Agent via mise, not a workload.** Replaces the removed `pi` workload approach: one generic
  [extensible-shell](extensible-shell.md) workload plus tool mixins compose a sandbox, instead of
  one workload kit per agent.
- **Depends on mise-en-place.** `mise use -g` needs the mise binary and its activation in the
  persistent env — declared as `requires: ["mise"]`, matching mise-en-place's `provides: ["mise"]`:
  composition fails closed without it, and the resolver orders the provider's overlay first.
- Version is pinned in the hook (`opencode@2.2.7`); bump there to upgrade.

Related: [extensible-shell.md](extensible-shell.md) · [mise-en-place.md](mise-en-place.md) · [summary.md](summary.md)
