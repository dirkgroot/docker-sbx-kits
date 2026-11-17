# git-identity-sign

Configures the Git identity inside the sandbox and turns on SSH-based commit signing, backed by an
injected SSH agent scoped to Git signing. Remote authentication is deliberately *not* handled here:
sandboxes authenticate to GitHub/GitLab via Docker Sandbox's secret injection with a fine-grained
personal access token, not with an SSH key that can reach everything the account can access.

- Source: `git-identity-sign/git-identity-sign.yaml`
- Kind: mixin · DisplayName: `Git identity + signing` · version 1.0.0
- Capabilities: `com.docker.sandbox/ssh-agent@1`, `com.docker.sandbox/lifecycle@1`
- Args: `git_user_name`, `git_user_email`, `git_user_signingKey` (all required)

## Capabilities

1. **ssh-agent** — `phase: runtime`, `unrestricted: false`, `sign: [git]`.
   The agent holds the signing key; sandbox processes never see key material directly, and agent use
   is scoped to signing Git commits only. The former `authenticate: [git@github.com]` was dropped on
   purpose: a fine-grained PAT injected as a sandbox secret is least-privilege and revocable
   independently of the account-wide SSH key.
2. **lifecycle startup** — runs at every sandbox boot:

```sh
git config set --global init.defaultBranch main
git config set --global commit.gpgsign true
git config set --global gpg.format ssh
git config set --global user.name       "${{ kit.args.git_user_name }}"
git config set --global user.email      "${{ kit.args.git_user_email }}"
git config set --global user.signingKey "${{ kit.args.git_user_signingKey }}"
```

## Invariants

- Any commit made in a sandbox with this kit is SSH-signed by default (`commit.gpgsign true`); unsigned
  commits fail until signing is explicitly disabled locally.
- New repos default to branch `main`.
- Identity and key arrive as kit args at sandbox creation; nothing identity-related is stored in this repo.
- Remote push/pull auth comes from injected secrets (fine-grained PAT), never from this kit's SSH
  agent — keep the agent sign-only.
