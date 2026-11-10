# Practices

Patterns this repo follows, plus rules inherited from the root [AGENTS.md](../AGENTS.md) (Lode Coding).

## Kit authoring

- One kit per directory; directory name = kit name; manifest at `<name>/<name>.yaml`.
- Every manifest opens with `# syntax=docker/sandbox-kit:3`, then a `# yaml-language-server: $schema=https://raw.githubusercontent.com/docker/sandbox-kit-spec/main/schema/kit.schema.json` modeline (the `# syntax=` line must stay first), then `schemaVersion: "3"`, `kind: mixin`, `displayName`.
- Pin capability majors explicitly (`@1`, `@2`) — the version is part of the contract.
- Declare every consumed value as a kit arg with `required: true` and an accurate `description`; interpolate with `${{ kit.args.NAME }}`.
- Prefer `lifecycle` hooks over bespoke entrypoint scripts: Dockerfile for image-time setup, `install` hooks once at sandbox creation (root by default; `user: "1000"` for agent-user work), `startup` hooks per boot.
- Never use `sudo` inside lifecycle hooks — hooks run under a filtered `env -i` environment with no TTY, so PAM auth fails. Use a root hook (omit `user`) for system changes, and prefer non-PAM tools there: `usermod -s` for login shells, not `chsh` (`/etc/pam.d/chsh` makes `pam_shells` a required check against `/etc/shells`, which this image doesn't ship; the failed `required` module defeats `pam_rootok`'s root bypass and even root hits a password prompt).
- Ship per-user config under `/home/agent` as lifecycle `files` entries (written as UID 1000, parents created, `overwrite: false` protects agent edits) — never as files in the mixin's own image layer, which would replace the workload's directory at that path, owner included.
- Startup commands that need the workspace path take it from `WORKSPACE_DIR` (`env: [WORKSPACE_DIR]`) and guard with `${WORKSPACE_DIR:?...}` to fail loudly when unset.
- Runtime egress is default-deny: any tool that downloads needs a matching `network-policy` allow for its domains (see [kits/mise-en-place.md](kits/mise-en-place.md)).
- Ship binaries with a two-stage Dockerfile: build in a normal image, then `COPY --from=build` into `FROM scratch` so the kit image carries only the artifact.

## Lode upkeep

- Update the lode in the same session as any kit change; the lode describes current state, never changelogs.
- One topic per file, kebab-case names, ≤250 lines, Mermaid-only diagrams, relative links between files.
- Session scraps go to `.lode/tmp/` (git-ignored); durable decisions go into topic files or `plans/`.
- The built-in `shell` agent launches `bash -l` regardless of `/etc/passwd`; mixins cannot change a
  workload's launch command. Passwd-level default shells apply only where the shell is looked up
  (SSH, `su`). The only mixin-side lever for changing what `sbx run shell` lands in is a guarded `exec`
  in `~/.bash_profile`.
- Source comments in kits explain *why* only, at most a line or two.
