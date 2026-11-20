# fish-shell-config

Mixin that writes fish's user configuration. No binaries, no dockerfile — pure lifecycle `files`.

- Source: `fish-shell-config/fish-shell-config.yaml`
- Kind: mixin · DisplayName: `Fish configuration` · version 1.0.0
- Capabilities: `lifecycle@1` (four `files` entries, no hooks)
- Requires: `fish-shell`

## Files written (UID 1000, all `overwrite: false`)

| Path | Purpose |
|---|---|
| `/home/agent/.config/fish/conf.d/colors.fish` | `LSCOLORS` / `LS_COLORS` |
| `/home/agent/.config/fish/conf.d/fish_frozen_theme.fish` | frozen color theme |
| `/home/agent/.config/fish/conf.d/fish_frozen_key_bindings.fish` | erases universal `fish_key_bindings` |
| `/home/agent/.config/fish/conf.d/abbreviations.fish` | docker / `kubens` abbreviations |

Config only — declares `requires: ["fish-shell"]`: without [fish-shell](fish-shell.md) in the set, resolution
fails closed instead of installing files no shell reads.

## Design decisions

- **`overwrite: false` everywhere**: agent edits to these files survive sandbox (re)creation.
- **Split from fish-shell** so binaries and config evolve independently: fish alone is a valid sandbox
  (default config), while this kit without fish is dead weight — the `requires` declaration makes that
  direction impossible at resolution rather than silently useless (see [summary.md](summary.md)).

## Invariants

- Config bodies live inline in the manifest; `lifecycle files` writes plain `$VAR` unchanged, so
  config bodies are safe unless they contain `${{`.

Related: [fish-shell.md](fish-shell.md) · [fish-shell-starship.md](fish-shell-starship.md)
