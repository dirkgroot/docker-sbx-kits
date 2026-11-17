# fish-shell-config

Mixin that writes fish's user configuration. No binaries, no dockerfile — pure lifecycle `files`.

- Source: `fish-shell-config/fish-shell-config.yaml`
- Kind: mixin · DisplayName: `Fish configuration` · version 1.0.0
- Capabilities: `lifecycle@1` (four `files` entries, no hooks)

## Files written (UID 1000, all `overwrite: false`)

| Path | Purpose |
|---|---|
| `/home/agent/.config/fish/conf.d/colors.fish` | `LSCOLORS` / `LS_COLORS` |
| `/home/agent/.config/fish/conf.d/fish_frozen_theme.fish` | frozen color theme |
| `/home/agent/.config/fish/conf.d/fish_frozen_key_bindings.fish` | erases universal `fish_key_bindings` |
| `/home/agent/.config/fish/conf.d/abbreviations.fish` | docker / `kubens` abbreviations |

Config only — needs the fish binary from [fish-shell](fish-shell.md) to be useful.

## Design decisions

- **`overwrite: false` everywhere**: agent edits to these files survive sandbox (re)creation.
- **Split from fish-shell** so binaries and config evolve independently and a sandbox can take one
  without the other (composability + separation of concerns; see [summary.md](summary.md)).

## Invariants

- Config bodies live inline in the manifest; `lifecycle files` writes plain `$VAR` unchanged, so
  config bodies are safe unless they contain `${{`.

Related: [fish-shell.md](fish-shell.md) · [fish-shell-starship.md](fish-shell-starship.md)
