# Practices

Patterns this repo follows, plus rules inherited from the root [AGENTS.md](../AGENTS.md) (Lode Coding).

## Kit authoring

- One kit per directory; directory name = kit name; manifest at `<name>/<name>.yaml`.
- Every manifest opens with `# syntax=docker/sandbox-kit:3`, then `schemaVersion: "3"`, `kind: mixin`, `displayName`.
- Pin capability majors explicitly (`@1`, `@2`) — the version is part of the contract.
- Declare every consumed value as a kit arg with `required: true` and an accurate `description`; interpolate with `${{ kit.args.NAME }}`.
- Prefer `lifecycle` hooks over bespoke entrypoint scripts: `install` for image-time setup, `startup` for per-boot setup.
- Startup commands that need the workspace path take it from `WORKSPACE_DIR` (`env: [WORKSPACE_DIR]`) and guard with `${WORKSPACE_DIR:?...}` to fail loudly when unset.
- Runtime egress is default-deny: any tool that downloads needs a matching `network-policy` allow for its domains (see [kits/mise-en-place.md](kits/mise-en-place.md)).
- Ship binaries with a two-stage Dockerfile: build in a normal image, then `COPY --from=build` into `FROM scratch` so the kit image carries only the artifact.

## Lode upkeep

- Update the lode in the same session as any kit change; the lode describes current state, never changelogs.
- One topic per file, kebab-case names, ≤250 lines, Mermaid-only diagrams, relative links between files.
- Session scraps go to `.lode/tmp/` (git-ignored); durable decisions go into topic files or `plans/`.
- Source comments in kits explain *why* only, at most a line or two.
