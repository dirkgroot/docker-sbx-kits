# Practices

Patterns this repo follows, plus rules inherited from the root [AGENTS.md](../AGENTS.md) (Lode Coding).

## Kit authoring

- One kit per directory; directory name = kit name; manifest at `<name>/<name>.yaml`.
- Every manifest opens with `# syntax=docker/sandbox-kit:3`, then a `# yaml-language-server: $schema=https://raw.githubusercontent.com/docker/sandbox-kit-spec/main/schema/kit.schema.json` modeline (the `# syntax=` line must stay first), then `schemaVersion: "3"`, `kind`, `version`, `displayName` — short and self-speaking, no kit-level `description`: pickers show the name alone, the kit's lode doc carries the detail.
- Pin capability majors explicitly (`@1`, `@2`) — the version is part of the contract.
- Declare every consumed value as a kit arg with `required: true` and an accurate `description`; interpolate with `${{ kit.args.NAME }}`.
- Prefer lifecycle hooks over bespoke setup scripts: Dockerfile for image-time setup, `install` hooks once at sandbox creation (root by default; `user: "1000"` for agent-user work), `startup` hooks per boot. The one sanctioned entrypoint exception is the composition seam: overriding the [extensible-shell](kits/extensible-shell.md) workload's `/home/agent/entrypoint.sh` with a lifecycle `files` entry (`overwrite: true`) to choose the sandbox's boot shell.
- Never use `sudo` inside lifecycle hooks — hooks run under a filtered `env -i` environment with no TTY, so PAM auth fails. Use a root hook (omit `user`) for system changes, and prefer non-PAM tools there: `usermod -s` for login shells, not `chsh` (`/etc/pam.d/chsh` makes `pam_shells` a required check against `/etc/shells`, which this image doesn't ship; the failed `required` module defeats `pam_rootok`'s root bypass and even root hits a password prompt).
- Ship per-user config under `/home/agent` as lifecycle `files` entries (written as UID 1000, parents created, `overwrite: false` protects agent edits) — never as files in the mixin's own image layer, which would replace the workload's directory at that path, owner included.
- Startup commands that need the workspace path take it from `WORKSPACE_DIR` (`env: [WORKSPACE_DIR]`) and guard with `${WORKSPACE_DIR:?...}` to fail loudly when unset.
- Runtime egress is default-deny: any tool that downloads needs a matching `network-policy` allow for its domains (see [kits/mise-en-place.md](kits/mise-en-place.md)).
- Ship binaries with a two-stage Dockerfile: build in a normal image, then `COPY --from=build` into `FROM scratch` so the kit image carries only the artifact.
- One workload per sandbox — [extensible-shell](kits/extensible-shell.md), built on a platform-floor template (`dhi.io/sbx-templates:shell-docker`: `USER agent`, `WORKDIR /home/agent/workspace`) whose `ENTRYPOINT` is a plain `/home/agent/entrypoint.sh` (`bash -l`) that mixins may override. Never add a new workload for a tool or agent; write a mixin instead. Shell-test a workload image with `docker run --entrypoint sh` — a bare `docker run <img> sh -c …` appends to the entrypoint and becomes a shell command.
- Install agents and tools in mixins via mise (`mise use -g <tool>@<pin>`), never as dedicated workloads, and give each such mixin the `network-policy` allows its downloads need (wildcard subdomains where downloads hit them).
- Settings a kit seeds into an agent's main config file must merge (existing keys retained, kit keys win), never blind-rewrite: install hooks run on every (re)create.

## Lode upkeep

- Update the lode in the same session as any kit change; the lode describes current state, never changelogs.
- One topic per file, kebab-case names, ≤250 lines, Mermaid-only diagrams, relative links between files.
- Session scraps go to `.lode/tmp/` (git-ignored); durable decisions go into topic files or `plans/`.
- The built-in `shell` agent launches `bash -l` regardless of `/etc/passwd`; passwd-level default
  shells apply only where the shell is looked up (SSH, `su`). With a self-owned workload, the
  mixin-side lever for what the sandbox boots into is overriding `/home/agent/entrypoint.sh`
  (`overwrite: true`) — fish-shell boots `fish -l` that way.
- Kit sources carry no rationale comments: the *why* lives in the kit's lode entry and the commit
  body. Source comments are rare, at most a line or two, explain *why* only, and never narrate fix
  history.
