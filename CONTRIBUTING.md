# Contributing

## Tooling

Tool versions are pinned in [`mise.toml`](./mise.toml). Install them with:

```bash
mise install
```

This provides `helm` and `helm-docs` at the versions CI uses.

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
  bumps `Chart.yaml`, the **Update Release Docs** workflow regenerates the
  README on the release PR branch and commits it back, so the badge tracks the
  new version without any manual step. That is why you never bump the version
  in the README yourself.

## Tests

The chart has [helm-unittest](https://github.com/helm-unittest/helm-unittest)
suites under `charts/curator/tests/`, run by the **Helm Unit Tests** workflow
on every PR. See [`charts/curator/tests/README.md`](./charts/curator/tests/README.md)
for how to run and write them.

```bash
helm unittest charts/curator
```
