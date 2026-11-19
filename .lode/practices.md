# Practices

Patterns this repo follows, plus rules inherited from the root [AGENTS.md](../AGENTS.md) (Lode Coding).

## Kit authoring

- One kit per directory; directory name = kit name; manifest at `<name>/<name>.yaml`.
- Every manifest opens with `# syntax=docker/sandbox-kit:3`, then a `# yaml-language-server: $schema=https://raw.githubusercontent.com/docker/sandbox-kit-spec/main/schema/kit.schema.json` modeline (the `# syntax=` line must stay first), then `schemaVersion: "3"`, `kind`, `version`, `displayName` — short and self-speaking, no kit-level `description`: pickers show the name alone, the kit's lode doc carries the detail.
- Top-level keys follow one canonical order reading as identity → interface → behavior:
  `schemaVersion`, `kind`, `displayName`, `version` (what the kit is), then `args` (what the user
  supplies), `provides` (what it offers other kits), `requires` (what it needs from them), then
  `capabilities` (the implementation, which consumes args). Kits omit absent keys but never reorder;
  `provides` precedes `requires`, mirroring the resolver (providers compose before requirers) and the
  spec schema's own property order.
- Pin capability majors explicitly (`@1`, `@2`) — the version is part of the contract.
- Never bump a manifest's `version` when changing a kit. Version assignment belongs to the release
  workflow (planned, see [roadmap](plans/roadmap.md)): it will publish kits as OCI images and give a
  new version only to kits that changed since the previous release. Until it exists, leave `version`
  untouched.
- Declare every consumed value as a kit arg with `required: true` and an accurate `description`; interpolate with `${{ kit.args.NAME }}`.
- Prefer lifecycle hooks over bespoke setup scripts: Dockerfile for image-time setup, `install` hooks once at sandbox creation (root by default; `user: "1000"` for agent-user work), `startup` hooks per boot. The one sanctioned entrypoint exception is the composition seam: overriding the [extensible-shell](kits/extensible-shell.md) workload's `/home/agent/entrypoint.sh` — the one way to do it is an install hook running as `user: "1000"` that rewrites the file (truncation keeps it agent-owned; `chmod 0700` restores the mode). Hooks run in dependency order, so requirers write after providers and win; lifecycle `files` must never touch that path (duplicate `files` paths are a composition error). A kit gates its write behind an `auto_start` arg, **opt-in by convention** (default
`false`): a composition sets it on exactly the one kit that should boot.
- Never use `sudo` inside lifecycle hooks — hooks run under a filtered `env -i` environment with no TTY, so PAM auth fails. Use a root hook (omit `user`) for system changes, and prefer non-PAM tools there: `usermod -s` for login shells, not `chsh` (`/etc/pam.d/chsh` makes `pam_shells` a required check against `/etc/shells`, which this image doesn't ship; the failed `required` module defeats `pam_rootok`'s root bypass and even root hits a password prompt).
- Ship per-user config under `/home/agent` as lifecycle `files` entries (written as UID 1000, parents created, `overwrite: false` protects agent edits) — never as files in the mixin's own image layer, which would replace the workload's directory at that path, owner included.
- Startup commands that need the workspace path take it from `WORKSPACE_DIR` (`env: [WORKSPACE_DIR]`) and guard with `${WORKSPACE_DIR:?...}` to fail loudly when unset.
- Runtime egress is default-deny, but install-phase egress is open while install hooks run
  (network-policy@2 is phase-scoped): only tools that download **at runtime** need a matching
  allow for their domains (see [kits/mise-en-place.md](kits/mise-en-place.md)); build-time and
  install-hook downloads need none.
- Ship binaries with a two-stage Dockerfile: build in a normal image, then `COPY --from=build` into `FROM scratch` so the kit image carries only the artifact.
- One workload per sandbox — [extensible-shell](kits/extensible-shell.md), built on a platform-floor template (`dhi.io/sbx-templates:shell-docker`: `USER agent`, `WORKDIR /home/agent/workspace`) whose `ENTRYPOINT` is a plain `/home/agent/entrypoint.sh` (`bash -l`) that mixins may override. Never add a new workload for a tool or agent; write a mixin instead. Shell-test a workload image with `docker run --entrypoint sh` — a bare `docker run <img> sh -c …` appends to the entrypoint and becomes a shell command.
- Install agents and tools in mixins via mise (`mise use -g <tool>@<pin>`), never as dedicated workloads, and give each such mixin the `network-policy` runtime allows any **session-time** downloads need (wildcard subdomains where downloads hit them) — the create-time tool download itself needs none (install-phase egress is open). mise-en-place owns `provides: ["mise-en-place"]`; mise-consuming mixins state `requires: ["mise-en-place"]`.
- Declare kit-to-kit dependencies with `provides`/`requires` (SPEC-v3 §5): the kit that ships a capability owns the `provide`, named after the declaring kit (mise-en-place provides `mise-en-place`; fish-shell provides `fish-shell`; unversioned unless the version is single-sourced in a kit arg), and every kit whose purpose needs it states a bare `require` naming that kit. Resolution is a closed-set check — composition fails closed without the provider, and the provider's overlay composes first.
- Settings a kit seeds into an agent's main config file must merge (existing keys retained, kit keys win), never blind-rewrite: install hooks run on every (re)create.

## Lode upkeep

- Update the lode in the same session as any kit change; the lode describes current state, never changelogs.
- One topic per file, kebab-case names, ≤250 lines, Mermaid-only diagrams, relative links between files.
- Session scraps go to `.lode/tmp/` (git-ignored); durable decisions go into topic files or `plans/`.
- The built-in `shell` agent launches `bash -l` regardless of `/etc/passwd`; passwd-level default
  shells apply only where the shell is looked up (SSH, `su`). With a self-owned workload, the
  mixin-side lever for what the sandbox boots into is rewriting `/home/agent/entrypoint.sh` from an
  install hook (the one way kits take the seam) — fish-shell boots `fish -l` that way, opencode
  `exec opencode`; each gates its write on its `auto_start` arg, opt-in by convention
  (default `false`), leaving the workload's `bash -l` when unset.
- Kit sources carry no rationale comments: the *why* lives in the kit's lode entry and the commit
  body. Source comments are rare, at most a line or two, explain *why* only, and never narrate fix
  history.
