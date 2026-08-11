# Contributing

## Tooling

Tool versions are pinned in [`mise.toml`](./mise.toml). Install them with:

```bash
mise install
```

This provides `helm`, `helm-docs`, and `node` at the versions CI uses.

## Commits and releases

Releases are automated with
[release-please](https://github.com/googleapis/release-please) and driven by
[Conventional Commits](https://www.conventionalcommits.org/). Every commit that
lands on `main` must follow that format (`feat:`, `fix:`, `docs:`, `chore:`,
…) — the **Verify Changes** workflow lints this on each PR.

- `feat:` → minor version bump, `fix:` → patch, `feat!:`/`BREAKING CHANGE:` →
  major.
- release-please keeps an open **release PR** that bumps
  `charts/curator/Chart.yaml` and the `CHANGELOG.md`. Merging it tags the
  version, and the **Release Charts** workflow then packages the chart and
  publishes the `curator-<version>` release + `index.yaml`.

You never edit the chart `version` by hand — release-please owns it.

## Release automation (GitHub App)

release-please runs with a token minted from a **GitHub App**, not the default
`GITHUB_TOKEN`. This is deliberate: pushes made with `GITHUB_TOKEN` do **not**
trigger other workflows, so the release PR would never get its CI checks and the
docs regeneration wouldn't run. An App installation token does trigger them.

**How it's wired.** The **Release Charts** workflow mints a short-lived,
repo-scoped token with `actions/create-github-app-token`, reading two
**organization** secrets (so the App can be reused across repos):

- `RELEASE_PLEASE_CLIENT_ID` — the App's client ID
- `RELEASE_PLEASE_APP_PRIVATE_KEY` — the App's private key (PEM contents)

**What the App needs.** It must be *installed on this repo*, and granted only:
Contents (read & write), Pull requests (read & write), and Issues (read & write,
for PR labels). The minted token inherits the App's permissions — it can be
scoped to a repo but not to fewer permissions — so keep the App minimal.

**Rotating the private key.** Generate a new key in the App's settings, update
the `RELEASE_PLEASE_APP_PRIVATE_KEY` org secret, then delete the old key. GitHub
lets multiple keys be valid at once, so this is zero-downtime.

**If release-PR checks stop running,** it's almost always this token: confirm
the org secrets still exist and are in scope for the repo, and that the App's
key hasn't been revoked or the App uninstalled.

## Documentation (helm-docs)

`charts/curator/README.md` is **generated** by
[helm-docs](https://github.com/norwoodj/helm-docs) from `Chart.yaml`,
`values.yaml` (including the `# --` comment annotations), and the templates.
Do not hand-edit it.

- **When you change `values.yaml` or templates in a PR**, regenerate the docs
  and commit the result:

  ```bash
  helm-docs --chart-search-root=charts
  git add charts/curator/README.md
  ```

  The **Check Helm Documentation** workflow fails the PR if the committed
  README doesn't match freshly generated output.

- **The version badge is handled for you at release time.** When release-please
  bumps `Chart.yaml`, the **Release Charts** workflow regenerates the README on
  the release PR branch and commits it back, so the badge tracks the new version
  without any manual step. That is why you never bump the version in the README
  yourself.

## Tests

The chart has [helm-unittest](https://github.com/helm-unittest/helm-unittest)
suites under `charts/curator/tests/`, run by the **Helm Unit Tests** workflow
on every PR. See [`charts/curator/tests/README.md`](./charts/curator/tests/README.md)
for how to run and write them.

```bash
helm unittest charts/curator
```
