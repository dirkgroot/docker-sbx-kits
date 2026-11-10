# git-identity-sign

Configures the Git identity inside the sandbox and turns on SSH-based commit signing, backed by an
injected SSH agent scoped to Git signing and GitHub authentication.

- Source: `git-identity-sign/git-identity-sign.yaml`
- DisplayName: `Git identity and commit signing`
- Capabilities: `com.docker.sandbox/ssh-agent@1`, `com.docker.sandbox/lifecycle@1`
- Args: `git_user_name`, `git_user_email`, `git_user_signingKey` (all required)

## Capabilities

1. **ssh-agent** — `phase: runtime`, `unrestricted: false`, `sign: [git]`, `authenticate: [git@github.com]`.
   The agent holds the signing key; sandbox processes never see key material directly, and agent use is
   scoped to signing Git and authenticating to GitHub.
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

## Known issue

- The `description` of `git_user_name` and `git_user_email` is a copy-paste of the signing-key description
  ("The public SSH key used for signing Git commits"). Tracked in [plans/roadmap.md](../plans/roadmap.md).
