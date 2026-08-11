# Chart unit tests

These are [helm-unittest](https://github.com/helm-unittest/helm-unittest) suites.
Each test renders `charts/curator` with a given set of values and asserts on the
resulting Kubernetes manifests — no cluster required.

## Running the tests

### One-time setup

Tools are pinned in [`mise.toml`](../../../mise.toml). From the repo root:

```bash
mise install                 # installs the pinned helm (and helm-docs)
helm plugin install https://github.com/helm-unittest/helm-unittest --version v1.1.1
```

### Run

```bash
# All suites
helm unittest charts/curator

# A single suite
helm unittest -f 'tests/service_test.yaml' charts/curator

# Verbose output (useful while debugging a failure)
helm unittest -d charts/curator
```

If `helm` isn't on your `PATH`, prefix commands with `mise exec --`, e.g.
`mise exec -- helm unittest charts/curator`.

### In CI

[`.github/workflows/helm-test.yml`](../../../.github/workflows/helm-test.yml) runs
`helm unittest charts/curator` on every pull request. It installs helm via mise so
CI uses the same version as local dev. Keep the suites green — a failure blocks the
check on the PR.

## Writing a test

### File layout

- Test files live in `charts/curator/tests/` and **must** be named `*_test.yaml`.
  The default discovery glob is `tests/*_test.yaml`; a file named anything else is
  silently ignored (this is why the original `deployment.yaml` never ran).
- Name the file after the template it exercises, e.g. `ingress.yaml` →
  `ingress_test.yaml`.

### Anatomy of a suite

```yaml
# yaml-language-server: $schema=https://raw.githubusercontent.com/helm-unittest/helm-unittest/main/schema/helm-testsuite.json
suite: test service            # human-readable suite name
templates:                     # which template(s) this suite renders
  - service.yaml
release:                       # optional: pin release name/namespace for stable output
  name: curator
capabilities:                  # optional: pin the cluster version the template sees
  majorVersion: 1
  minorVersion: 21
tests:
  - it: defaults to ClusterIP on port 8080   # describe the behaviour
    set:                                      # override values for this case
      service.type: NodePort
      service.port: 9090
    asserts:
      - isKind:
          of: Service
      - equal:
          path: spec.ports[0].port
          value: 9090
```

The first line (`# yaml-language-server: ...`) enables schema completion and
validation in editors — keep it at the top of every suite.

### Assertions used in these suites

| Assertion | Purpose | Example |
| --- | --- | --- |
| `isKind` / `isAPIVersion` | check the rendered kind / apiVersion | `isKind: {of: Deployment}` |
| `equal` | exact value at a path | `equal: {path: spec.type, value: ClusterIP}` |
| `matchRegex` | regex match at a path | `matchRegex: {path: metadata.name, pattern: -server$}` |
| `notExists` | a path is absent | `notExists: {path: spec.replicas}` |
| `hasDocuments` | number of rendered docs (0 = template produced nothing) | `hasDocuments: {count: 0}` |
| `failedTemplate` | rendering fails with an expected message | `failedTemplate: {errorMessage: "..."}` |

Full list: <https://github.com/helm-unittest/helm-unittest/blob/main/DOCUMENT.md>.

### Path syntax tips

- Index into lists with `[0]`: `spec.rules[0].http.paths[0].path`.
- Keys containing dots or slashes need bracket-quoting:
  `metadata.annotations["eks.amazonaws.com/role-arn"]`.

## Chart-specific gotchas

These behaviours of this chart trip up tests if you don't account for them:

- **`environment` defaults to `prod`, and that alone renders the HPA.**
  `hpa.yaml` renders when `environment == "prod"` **or** `autoscaling.enabled` is
  true. To assert "no HPA", set `environment: dev` **and** `autoscaling.enabled:
  false`.
- **`image.tag` is validated by `checkImageTag`.** The deployment fails to render
  unless `image.tag` is set and is either a valid `YYYY.MM.DD`-style version, or
  contains `latest`/`dev`, or `image.tagOverride` is set. Tests here use
  `image.tag: latest` to skip the version check.
- **`podDisruptionBudget` requires exactly one of `maxUnavailable` / `minAvailable`.**
  With neither (the default) or both set, the template calls `fail` — assert those
  cases with `failedTemplate`.
- **Ingress `apiVersion` depends on the cluster version.** The template switches on
  `.Capabilities.KubeVersion`, so pin `capabilities.minorVersion` in the suite if
  you assert on `apiVersion` (these tests pin `1.21` to get `networking.k8s.io/v1`).
- **Names come from the release name.** Templates use `curator.fullname` /
  `curator.serviceAccountName`, which derive from `.Release.Name`. Set `release.name`
  in the suite so expected names are stable rather than the default `RELEASE-NAME`.

## Coverage

The suites intentionally cover a first slice (~25%) of `values.yaml`: `image`,
`service`, `serviceAccount`, `autoscaling`/HPA, `ingress`, and
`podDisruptionBudget`. Good next candidates: `persistence`, `mariadbOperator`,
`curator.{env,sentry,config}`, `cronjob`, `resources`, and pod scheduling
(`nodeSelector` / `tolerations` / `affinity` / `topologySpreadConstraints`).
