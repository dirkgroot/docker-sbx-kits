# Roadmap / TODOs

Open items and known inconsistencies. Remove entries once fixed; fixes belong in the topic files, not
here — no changelogs.

- Release workflow: publish kits to a registry as OCI images from GitHub Actions, giving a new
  version only to kits that changed since the previous release. Until it exists, manifest `version`
  fields stay untouched — agents must not bump them.
