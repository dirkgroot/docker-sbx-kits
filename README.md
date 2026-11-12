# sbx-kits

A personal collection of [Docker Sandbox](https://docs.docker.com/) kits: reusable mixins and agent workloads that customize sandboxes built
with the `sbx` CLI.

## Kits

Each kit is a self-contained directory with a YAML manifest declaring capabilities and the args they consume. Some kits
also ship a Dockerfile for staged installation.

| Kit                                        | Purpose                                                                       | Capabilities                      |
|--------------------------------------------|-------------------------------------------------------------------------------|-----------------------------------|
| [`agent-context/`](agent-context/)         | Injects a personal `AGENTS.md` into the agent config directory                | `agent-context@1`                 |
| [`git-identity-sign/`](git-identity-sign/) | Configures Git identity with SSH commit signing                               | `ssh-agent@1`, `lifecycle@1`      |
| [`mise-en-place/`](mise-en-place/)         | Installs and activates the `mise` tool manager                                | `network-policy@2`, `lifecycle@1` |
| [`fish-starship/`](fish-starship/)         | Installs fish shell + starship prompt; fish as the `agent` user's login shell | `lifecycle@1`                     |
| [`pi/`](pi/)                               | **Workload:** runs [Pi](https://pi.dev/) as the sandbox's agent                | `sbx@1`, `lifecycle@1`, sessions, credentials, egress |

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

## Documentation

- [Author kits](https://docs.docker.com/ai/sandboxes/customize/author/) — descriptor and Dockerfile layout, capabilities, lifecycle hooks
- [Use kits](https://docs.docker.com/ai/sandboxes/customize/use-kits/) — running and combining kits with `sbx run` and `--kit`
- [Build and distribute kits](https://docs.docker.com/ai/sandboxes/customize/author/distribute/) — publishing kit images to a registry
- [docker/sbx-kits-contrib](https://github.com/docker/sbx-kits-contrib) — Docker's community kit sources and kit spec
- Tools shipped by these kits: [mise](https://mise.jdx.dev/), [fish](https://fishshell.com/), [starship](https://starship.rs/)
