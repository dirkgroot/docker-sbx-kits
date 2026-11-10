# dev-port

Publishes a single TCP port from the sandbox to the host, for reaching a dev server started inside the
sandbox.

- Source: `dev-port/dev-port.yaml`
- DisplayName: `Development server host port`
- Capabilities: `com.docker.sandbox/port@1`
- Args: `port` (required)

## Manifest

```yaml
args:
  port:
    required: true

capabilities:
  - type: com.docker.sandbox/port@1
    config:
      container: ${{ kit.args.port }}
      transport: tcp
```

## Notes

- `port` is the sandbox-side port; the kit does not pin a host-side port.
- TCP only. The published port reaches services that listen on `0.0.0.0` (not loopback-only).
- The manifest publishes exactly one port; vary the `port` arg per sandbox rather than editing the kit.
