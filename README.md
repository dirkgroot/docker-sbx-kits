# sbx-kits

A personal collection of [Docker Sandbox](https://docs.docker.com/) kits: one extensible base workload and reusable mixins that customize
sandboxes built with the `sbx` CLI.

## Kits

Each kit is a self-contained directory with a YAML manifest declaring capabilities and the args they consume. Some kits
also ship a Dockerfile for staged installation.

| Kit                                        | Purpose                                                                       | Capabilities                      |
|--------------------------------------------|-------------------------------------------------------------------------------|-----------------------------------|
| [`extensible-shell/`](extensible-shell/)   | **Workload:** bare shell sandbox with an overridable entrypoint               | —                                 |
| [`agent-context/`](agent-context/)         | Injects a personal `AGENTS.md` into the agent config directory                | `agent-context@1`                 |
| [`git-identity-sign/`](git-identity-sign/) | Configures Git identity with SSH commit signing                               | `ssh-agent@1`, `lifecycle@1`      |
| [`mise-en-place/`](mise-en-place/)         | Installs and activates the `mise` tool manager                                | `network-policy@2`, `lifecycle@1` |
| [`fish-shell/`](fish-shell/)               | Installs fish, makes it the `agent` user's login shell                        | `lifecycle@1`                     |
| [`fish-shell-config/`](fish-shell-config/) | Fish configuration drop-ins: colors, theme, key bindings, abbreviations       | `lifecycle@1`                     |
| [`fish-shell-starship/`](fish-shell-starship/) | Installs the starship prompt and wires it into fish                       | `lifecycle@1`                     |
| [`opencode/`](opencode/)                   | Installs the [OpenCode](https://opencode.ai/) coding agent via `mise`         | `network-policy@2`, `lifecycle@1` |

## Kit anatomy

```
<kit>/
    <kit>.yaml            # manifest: displayName, args, capabilities[]
    <kit>.dockerfile      # optional, for two-stage installs
```

- **Capabilities** are versioned units of customization: `agent-context@1`, `ssh-agent@1`, `lifecycle@1`,
  `network-policy@2`.
- **Args** (e.g. `git_user_name`, `git_user_email`, `git_user_signingKey`) are declared under `args:` and referenced as
  `${{ kit.args.NAME }}`.

## Auto-start

The `extensible-shell` workload starts a bash terminal by default: its `bash -l` entrypoint is the sandbox's login
surface. Mixins that ship a bootable program — [`fish-shell/`](fish-shell/) and [`opencode/`](opencode/) — declare an
`auto_start` arg (default `false`) that overrides this behaviour: when set to `true`, the mixin rewrites the entrypoint
at install time so its own program starts instead of bash.

- Leave `auto_start` unset (or `false`) to boot into the default bash terminal.
- Set `auto_start: true` on exactly one mixin per composition — the one that should take over the boot shell
  (`fish -l` for `fish-shell`, `opencode` for `opencode`).

## Documentation

- [Author kits](https://docs.docker.com/ai/sandboxes/customize/author/) — descriptor and Dockerfile layout, capabilities, lifecycle hooks
- [Use kits](https://docs.docker.com/ai/sandboxes/customize/use-kits/) — running and combining kits with `sbx run` and `--kit`
- [Build and distribute kits](https://docs.docker.com/ai/sandboxes/customize/author/distribute/) — publishing kit images to a registry
- [docker/sbx-kits-contrib](https://github.com/docker/sbx-kits-contrib) — Docker's community kit sources and kit spec
- Tools shipped by these kits: [mise](https://mise.jdx.dev/), [fish](https://fishshell.com/), [starship](https://starship.rs/), [opencode](https://opencode.ai/)
