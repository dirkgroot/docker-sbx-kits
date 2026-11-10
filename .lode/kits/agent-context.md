# agent-context

Injects the user's personal agent-tuning rules as an `AGENTS.md` file into the OpenCode config directory
of every sandbox that uses this kit.

- Source: `agent-context/agent-context.yaml`
- DisplayName: `My personal AGENTS.md`
- Capabilities: `com.docker.sandbox/agent-context@1`
- Args: none

## Behavior

```yaml
capabilities:
  - type: com.docker.sandbox/agent-context@1
    config:
      filename: AGENTS.md
      directory: /home/agent/.config/opencode
      content: |
        # INTJ — Agent Tuning Rules
        ...
```

The `content` blob is the full INTJ interaction ruleset (lead with conclusions, cut hedges, frameworks over
examples, push back with evidence, terse defaults). It is written verbatim to
`/home/agent/.config/opencode/AGENTS.md`.

## Invariants & cautions

- The capability is required (not `optional`): a sandbox using this kit fails to build if the
  agent-context capability is unavailable. The injected `AGENTS.md` is treated as essential, not
  best-effort.
- This file is distinct from the repo-root `AGENTS.md`, which is the Lode Coding method, not personal tuning.
- The rules have no separate source file; edits happen directly in the manifest's `content` block.
