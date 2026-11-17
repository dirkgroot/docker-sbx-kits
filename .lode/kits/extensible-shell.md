# extensible-shell

The repo's baseline **workload**: a bare, generic shell sandbox whose entrypoint is deliberately
overridable, so mixins decide what the sandbox actually boots into.

- Source: `extensible-shell/extensible-shell.yaml` + `extensible-shell/extensible-shell.dockerfile`
- Kind: `workload` (the repo's only one) · DisplayName: `Extensible shell` · version 1.0.0
- Capabilities: none — everything it does happens at image build time

## Role in the architecture

sbx-kits follows a **compose-don't-specialize** model: one generic workload is the base of every
sandbox, and small focused mixins layer capabilities on top. Agents are *not* workloads — the `pi`
workload worked that way and was removed — they are mixins that install the agent binary,
preferably via [mise-en-place](mise-en-place.md).

```mermaid
flowchart TD
    es["extensible-shell workload<br/>dhi.io/sbx-templates:shell-docker<br/>entrypoint.sh → bash -l"] --> m["mixins layer on top"]
    m --> fs["fish-shell<br/>overrides entrypoint.sh → fish -l"]
    m --> oc["opencode<br/>agent via mise"]
    m --> gi["git-identity-sign"]
    m --> me["mise-en-place"]
```

## The entrypoint contract

- The Dockerfile writes `/home/agent/entrypoint.sh` (`bash -l`, mode 0700) and sets it as
  `ENTRYPOINT` — the sandbox's login surface.
- The file lives under `/home/agent` so mixins can replace it: the one way to take the seam is an
  install hook running as `user: "1000"` that rewrites the file (truncation keeps it agent-owned;
  `chmod 0700` restores the mode) — hooks run in dependency order, so requirers write after
  providers and win, and lifecycle `files` must not touch the path (duplicate `files` paths are a
  composition error). [fish-shell](fish-shell.md) boots into fish this way, gated on its
  `override_entrypoint` arg (default `true`).
- Base image `dhi.io/sbx-templates:shell-docker` carries the platform floor (`USER agent`,
  `WORKDIR /home/agent/workspace`).

## Invariants

- The workload stays capability-free and tool-free; every capability or tool must come from a mixin.
- The entrypoint must remain a plain script under `/home/agent` — that path choice is what makes
  mixin overrides possible.
- Default `bash -l` keeps the sandbox usable with zero mixins.

Related: [summary.md](summary.md) · [fish-shell.md](fish-shell.md) · [opencode.md](opencode.md) · [../practices.md](../practices.md)
