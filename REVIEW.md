# Review Standards

Standards a PR should meet before merging. Read by human reviewers and by
the automated reviewer (Themis, in `.github/workflows/claude-code-review.yml`).

`CONTRIBUTING.md` is the *development* guide -- how to work in this repo
(tooling via mise, conventional commits, the release-please flow, helm-docs,
how to run the tests). This file is the *review* guide -- what a reviewer
(human or bot) should evaluate before approving a PR. Different audiences,
different files; don't conflate them.

Note: Renovate and release-please PRs are authored by Bot accounts and are
intentionally **not** reviewed by Themis -- the workflow skips any PR whose
author is a Bot. This file applies to human-authored PRs.

## Repository under review

`curator-helm` publishes a single Helm chart, `charts/curator`, which deploys
InterWorks' **Curator** (a Laravel/PHP app) onto Kubernetes. The chart is the
only product here; everything else in the repo exists to test, document, and
release it.

- `charts/curator/templates/` renders the Deployment, CronJob, bootstrap Jobs,
  Service, Ingress, HPA, PDB, PVC, ServiceAccount, ExternalSecrets, and the
  mariadb-operator `Database` / `User` / `Grant` / `Backup` resources.
- `charts/curator/values.yaml` is the public interface, `values.schema.json`
  is validated at render time, and `charts/curator/README.md` is **generated**
  by helm-docs from both.
- `charts/curator/tests/` holds helm-unittest suites.
- Releases are automated: conventional commits -> release-please version bump
  PR -> tag -> chart-releaser publishes the packaged chart and `index.yaml`.

**The consumer is the fleet.** Released chart versions are pinned by
per-site HelmReleases in `InterWorks/iac-interworks` and reconciled by Flux
across every Curator tenant. A values key that changes shape, or a default
that changes value, reaches every site that bumps the chart. Review with
that blast radius in mind.

Review as a principal Kubernetes / Helm engineer who is also fluent in how a
Laravel app boots: someone who guards the values interface, the rendered
manifest correctness, the database wiring, and the release automation.

## CI environment notice (for the bot)

This review runs in GitHub Actions with **no** Kubernetes cluster, **no**
`helm` binary, and **no** cluster credentials. Use only `Read`, `Grep`,
`Glob`, `Write`, and the allowlisted `git` / `gh` Bash commands. Do not try
to run `helm template`, `helm unittest`, `helm-docs`, or `kubectl` -- the
Helm Unit Tests and Check Helm Documentation workflows run those
independently on each PR. Reason about rendered output by reading the
templates.

## What CI already covers (do not flag)

These run on every PR, independently of this review. Do not raise findings
these checks already enforce.

- **Helm unit tests** (`.github/workflows/helm-test.yml`): `helm unittest
  charts/curator`. A rendering failure or a broken assertion fails the PR, so
  don't re-flag Go-template syntax errors or output that a green suite
  already pins.
  **Caveat, and it is a big one:** suites exist only for `deployment`, `hpa`,
  `ingress`, `pdb`, `service`, and `serviceaccount`, and each suite exercises
  one set of values. `cronjob.yaml`, `job-create-admin.yaml`,
  `job-db-migrate.yaml`, `configmap.yaml`, `pvc.yaml`, the `externalsecrets-*`
  and `mariadb-*` templates, and every conditional branch no suite sets
  (`persistence.s3.enabled`, `autoscaling.enabled`, `maxscaleEndpoint`,
  `mariadbNamespace`, `curator.config`, `envFromSecret`) are **unverified**.
  Read those paths and reason about them yourself.
- **helm-docs check** (`.github/workflows/helm-docs.yml`): regenerates docs
  and fails if `charts/curator/README.md` doesn't match. Don't flag a stale
  README, and never ask for a hand-edit of it. Do flag a **missing `# --`
  annotation** on a new value key -- helm-docs emits a blank description and
  CI stays green (see *Values interface* below).
- **commitlint** (`.github/workflows/verify.yml`): every commit in the PR
  must be a conventional commit. Don't flag commit-message *format*. Do flag
  a wrong **type** or missing breaking-change marker, which commitlint can't
  judge and which drives the released version (see *Release automation*).

If a finding would duplicate one of these, drop it.

There is **no** kubeconform, kube-linter, `helm lint`, or secret scanner in
this repo. Invalid Kubernetes fields, wrong `apiVersion`s, bad `nindent`
depth, and leaked credentials reach `main` unless a reviewer catches them.
Those are all fair -- and expected -- findings here.

## Project conventions worth checking

### Secrets (hard rule)

No scanner runs on this repo, which makes the reviewer the only gate.

- **Never commit plaintext secrets.** Credentials reach the pod through
  `ExternalSecret` resources (`externalsecrets-db.yaml`,
  `externalsecrets-admin.yaml`), a `secretKeyRef` to an operator-managed
  secret, or `curator.envFromSecret`. Treat any password, token, DSN with
  credentials, or connection string committed to `values.yaml`,
  `test-values.yaml`, a template, or a test fixture as a must-fix finding --
  call it out first and unambiguously. A real Sentry DSN counts.

### The values interface is a public API

Every key in `values.yaml` is consumed by per-site HelmReleases in
`iac-interworks`. Flux renders the chart in-cluster with values that this
repo never sees, and a key that no longer exists renders silently to nothing
rather than erroring.

- **Renaming, removing, or re-nesting a key is a breaking change.** It needs
  `feat!:` or a `BREAKING CHANGE:` footer so release-please cuts a major, and
  the PR should say what fleet-side change is required. Prefer keeping the
  old key working (defaulting the new from the old) over a hard cutover.
- **Changing a default value changes every site that bumps the chart.**
  Resource sizing, probe thresholds, `replicaCount`, PDB settings, backup
  schedule/retention: a silent default change is a fleet-wide change. Flag
  one that isn't called out in the PR.
- **New keys need a `# --` helm-docs annotation** immediately above them, and
  a sensible default. Without the annotation, the generated README documents
  the key with an empty description and the docs check still passes.
- **Keep `values.schema.json` and the templates in agreement.** The schema is
  enforced at render, so adding a `required` key or narrowing an `enum`
  breaks existing releases at reconcile time, not at review time. Also flag
  the reverse drift: a template branching on a value the schema forbids is
  dead code. (Live example: `curator.resources` in `_helpers.tpl` compares
  `.Values.environment` to `"production"`, but the schema's enum is
  `dev | qa | prod`, so the production sizing branch can never be taken.)

### Database wiring (the repo's most-broken area)

Three of the last five `fix:` commits were here (`#70` DB_HOST missing from
the CronJob, `#73` the last `mariadbEndpoint` fallback case, `#75` `-primary`
on the app's `db_host`). Give this area more scrutiny than its diff size
suggests.

- **`DB_HOST` is set in four places and is not part of the shared env
  block.** `_env.tpl`'s `env.environment` deliberately omits it;
  `deployment.yaml` and `cronjob.yaml` set it from the `curatorDbEndpoint`
  helper, while `job-create-admin.yaml` and `job-db-migrate.yaml` hand-roll
  a `<mariadbName>-primary.<namespace>` value. Flag a change to
  `curatorDbEndpoint` that isn't considered for all four consumers, and flag
  any new pod spec that includes `env.environment` without also setting
  `DB_HOST`.
- **The `-primary` suffix on the write path is deliberate, not a typo.**
  Migration and admin-creation jobs must hit the primary; routing them at a
  replica gives read-only failures. Don't "simplify" those two to the shared
  helper, and do flag a new write-path workload that resolves to the
  replica-capable endpoint.
- **`curatorDbEndpoint` resolves in a fixed order**: maxscale (with
  namespace) -> `mariadbEndpoint` (with namespace) -> `mariadbEndpoint`
  (release namespace) -> `mariadbName` (release namespace). A new branch or
  a reordering changes which host live sites resolve to. Check each arm
  renders a fully-qualified, correct host, and that a value combination the
  branches don't cover can't fall through to a wrong default.

### Release automation (release-please owns the version)

- **Never hand-edit** `charts/curator/Chart.yaml`'s `version`,
  `charts/curator/CHANGELOG.md`, `.release-please-manifest.json`, or the
  README's version badge. release-please owns all four, and a manual bump
  desynchronizes the manifest from the tags. Flag any human PR that touches
  them.
- **`appVersion` is hand-managed** (release-please does not touch it) and
  names the Curator application release the chart defaults to. Renovate keeps
  `image.tag`'s digest current on its own, so the two don't move in lockstep;
  what's worth flagging is an `appVersion` bump in a PR that changes nothing
  else about the app defaults, or a human `image.tag` change that leaves a
  now-wrong `appVersion` behind.
- **The commit type is the version bump.** `fix:` -> patch, `feat:` ->
  minor, `feat!:` / `BREAKING CHANGE:` -> major. A values-interface change
  labeled `fix:` ships a breaking change as a patch to the whole fleet.
  Flag the mislabel, not the message wording.

### Image pins

- `image.tag` is digest-pinned (`latest@sha256:...`) and Renovate-managed.
  Flag a hand-edit that **unpins** it (drops the `@sha256:` digest), points
  it at a different repository/registry, or moves it **backward** -- Renovate
  only moves pins forward, so a backward move in a human PR is most likely an
  accidental regression. A deliberate, stated rollback is fine.
- `_image-tag-check.tpl` fails the render for tags below the `2025.5.1`
  minimum, and skips the check for tags containing `dev` or `latest`.
  Changing that guard's threshold or its escape hatches is a fleet-visible
  change; flag it if the PR doesn't say why.

### Manifest correctness

Nothing validates rendered output against the Kubernetes API here, so read
for it:

- Correct `apiVersion` / `kind` pairs for the cluster's Kubernetes version,
  and for the mariadb-operator and External Secrets CRDs.
- `nindent` depth matching the surrounding block. An off-by-two indent
  produces valid YAML with fields on the wrong parent, which no test catches.
- Labels and selectors from `curator.labels` / `curator.selectorLabels` --
  changing a selector on an existing Deployment is an immutable-field error
  at upgrade time, not a render error.
- Probe changes: `/ping` is deliberately dependency-free on liveness and
  startup, and `/healthz` (DB-aware) is deliberately readiness-only. Flag a
  change that puts a database-aware endpoint on the liveness probe -- that
  restarts every pod at once during a DB blip instead of pulling them from
  the Service.

### Tests

- **A new or changed template should come with a suite** in
  `charts/curator/tests/`, especially for the templates listed as uncovered
  above. A bug fix should come with a test that would have failed before it.
- **Test files must be named `*_test.yaml`.** The discovery glob is
  `tests/*_test.yaml`; anything else is silently ignored and never runs (this
  has already happened once in this repo). Flag a suite added under any other
  name.

### Workflows

- Third-party actions are **SHA-pinned with a version comment**; flag one
  pinned to a mutable tag or left unpinned.
- Jobs run on the self-hosted pools (`us-east-2-development`,
  `us-east-2-development-docker`) and install tooling with `mise` from
  `mise.toml`. Don't flag the self-hosted runner choice. Do flag a workflow
  that installs `helm`, `helm-docs`, or `node` at a version other than the
  one `mise.toml` pins -- a generator version mismatch breaks the docs check.

## What is *not* a finding

- Style nits a linter or formatter would (or wouldn't) flag, and YAML
  formatting preferences in the chart templates.
- Speculative concerns -- "what if someday".
- "You could also consider..." suggestions.
- Naming preferences when the existing name is reasonable.
- Requests for comments unless the *why* is genuinely non-obvious.
- The generated `charts/curator/README.md` diff itself, when it matches the
  values change in the same PR. That file is machine-written; review the
  `values.yaml` change instead.
- Missing tests on a docs-only, comment-only, or CI-only change.
- The self-hosted runner pools, including a SHA-pinned third-party action
  running on one; that tradeoff is accepted here.

## State facts, not intent

You can see the diff; you cannot see *why* the author made it. Describe what
the change does and let the author confirm the why -- never assert intent as
fact.

- Say *"this drops the `mariadbNamespace` arm from `curatorDbEndpoint`, so
  external-namespace sites now resolve to the release namespace -- is that
  intended?"*, not *"this correctly simplifies the endpoint helper"* **or**
  *"this breaks external-namespace sites."* You don't know which -- name the
  fact and ask.
- Don't manufacture a rationale to approve a questionable change, and don't
  invent a motive to condemn one.
- On a re-review, if new commits change your read, state what *factually*
  changed since the prior version; don't retroactively re-narrate the
  author's intent or contradict a verdict you stated before without saying
  what moved.

## Bar for a must-fix finding

Themis runs in **comment-only** mode here: every review is a non-blocking
`COMMENT` -- it never approves or requests changes, so it never blocks a PR.
Call the issues below out prominently as must-fix. The bar is *"this is
wrong"*, not *"this could be better"*:

- A plaintext secret or credential anywhere in the repo.
- A values key renamed, removed, or re-nested without a breaking-change
  marker, or a changed default the PR doesn't call out.
- A `values.schema.json` change that would fail an existing site's render, or
  schema/template drift that makes a branch unreachable.
- A database-wiring change that leaves the four `DB_HOST` consumers
  inconsistent, or routes a write-path workload off `-primary`.
- A hand-edit of `Chart.yaml`'s `version`, `CHANGELOG.md`, or
  `.release-please-manifest.json`, or a commit type that ships a breaking
  change as a patch.
- An unpinned, redirected, or backward-moved `image.tag` without a stated
  rollback.
- A rendered manifest that is invalid or wrong: bad `apiVersion`/`kind`,
  misindented block, mutated Deployment selector, DB-aware liveness probe.
- A test suite added under a filename that helm-unittest won't discover.
- A bug or incorrect logic in a template helper, workflow, or script.
- A documented or load-bearing invariant the diff violates.

If you don't find one of those, say so in one line -- don't pad the comment
with style nits or "you could also consider" suggestions.

## Closing line: feedback on the review

After the findings -- whether or not you raised any -- end every review with
this exact one-line invitation, so a reader who thinks the review missed the
mark has an easy way to flag it:

> _Didn't do a good job on this review? Add the `claude_bad` label to this PR so the team can flag it for improvement._

Keep it to that single line, as the last thing in the comment.
