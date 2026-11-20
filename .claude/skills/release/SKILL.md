---
name: release
description: >-
  Create a new GitHub release of this repository with gh: pin the self-referencing pre-commit hook to the current
  version, push the default branch, push the next tag, wait for the tag CI workflow to succeed, create the release,
  then pin the pre-commit hook to the new version and move the tag onto that commit. Use when the user asks to
  "release", "create a release", "publish a new version" or "tag a new version". Optional argument: patch (default),
  minor, major or an explicit X.Y.Z version.
argument-hint: '[patch|minor|major|X.Y.Z]'
---

# Release

Requested version bump: `$ARGUMENTS` (empty means: ask the user, default patch).

Run every command from the repository root. Shell variables do not persist between Bash calls: re-define the values you
need (`DEFAULT_BRANCH`, `CURRENT`, `NEXT`) in each call, or substitute their literal values.

- Helper script: `.claude/skills/release/scripts/release-helper.sh` (called `helper` below).
- Tags are lightweight `X.Y.Z` tags (no `v` prefix).
- CI workflow: `.github/workflows/main.yml`, triggered on tag push (override with `RELEASE_WORKFLOW=<file>`).
- `.pre-commit-config.yaml` references this repository's own hooks (`- repo: https://github.com/<owner>/<repo>` +
  `rev:`). That `rev` must always point to an existing tag: it is first pinned to the current version, and moved to the
  new version only once that tag exists. `.pre-commit-config-github.yaml` is gitignored (generated in CI from
  `.pre-commit-config.yaml`): never commit it.

## 1. Preconditions (stop and report if one fails)

```bash
gh auth status
DEFAULT_BRANCH="$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)"
git switch "${DEFAULT_BRANCH}"
git status --porcelain # must be empty: never commit unrelated work
git fetch --tags origin
git pull --ff-only
```

Compute versions:

```bash
CURRENT="$(.claude/skills/release/scripts/release-helper.sh current-version)"
NEXT="$(.claude/skills/release/scripts/release-helper.sh next-version patch)" # or minor|major|X.Y.Z
```

If no argument was given, show the commits since `${CURRENT}` (`git log --oneline "${CURRENT}..HEAD"`) and ask the user
(AskUserQuestion) to pick the patch, minor or major version (patch first, recommended). Abort if there are no commits
since `${CURRENT}`, or if tag `${NEXT}` already exists locally (`git tag -l "${NEXT}"`) or remotely
(`git ls-remote --tags origin "refs/tags/${NEXT}"`).

## 2. Pin pre-commit to the current version

```bash
.claude/skills/release/scripts/release-helper.sh update-precommit "${CURRENT}"
```

It rewrites the `rev` of the self-referencing repo entry and prints `.pre-commit-config.yaml` if it was modified. If so,
commit it (commit message format from `.github/commit-message.instructions.md`, plus the attribution lines required by
the session; use the actual repository name):

```bash
git add .pre-commit-config.yaml
git commit -m "🔖(pre-commit): Use bash-tools-framework ${CURRENT} hooks" -m "<attribution>"
```

Pre-commit hooks run on commit: if they only reformat/regenerate files, `git add` those files and commit again; if they
fail for real, stop and report.

## 3. Push the default branch

```bash
git push origin "${DEFAULT_BRANCH}"
```

Pre-push hooks may run. Never use `--no-verify` and never force push the branch.

## 4. Create and push the tag

```bash
git tag "${NEXT}"
git push origin "refs/tags/${NEXT}"
```

## 5. Wait for the tag workflow

The CI (docker images, pre-commit, MegaLinter, bats matrix) takes a long time: run this with the Bash tool option
`run_in_background: true` and wait for the completion notification (do not poll its output):

```bash
.claude/skills/release/scripts/release-helper.sh wait-run "${NEXT}"
```

It finds the `main.yml` run for the tag at the tag commit (waiting up to 10 min for it to appear), watches it, and exits
non-zero with failing jobs and a log excerpt if it does not succeed.

On failure: do NOT create/update the release. Show the user the failing jobs and the log excerpt, and ask how to proceed
(fix then move the tag, `gh run rerun <id> --failed`, or abort). Never delete a pushed tag without the user's approval.

## 6. Create the release

First pass (`gh release view "${NEXT}"` fails, the release does not exist yet): write release notes to a file in the
scratchpad directory, in the style of the previous release (`gh release view "${CURRENT}" --json body -q .body`): a
short summary of the changes in `git log --format='%s%n%b' "${CURRENT}..${NEXT}"` grouped by type (Features, Bug Fix,
Documentation, Chore, ...), ending with:

```text
**Full Changelog**: https://github.com/<owner>/<repo>/compare/<CURRENT>...<NEXT>
```

```bash
gh release create "${NEXT}" --verify-tag --title "${NEXT}" --notes-file "<scratchpad>/release-notes.md" --latest
```

Later passes (after the tag was moved in step 6): the release already exists and follows the tag name. Only check it
with `gh release view "${NEXT}" --json tagName,url,isDraft`; if it became a draft, publish it with
`gh release edit "${NEXT}" --draft=false --latest`.

## 7. Pin pre-commit to the new version (if needed) and move the tag

```bash
.claude/skills/release/scripts/release-helper.sh update-precommit "${NEXT}"
```

- Nothing printed (`rev` already equals `${NEXT}`): the release is done, go to the report.

- `.pre-commit-config.yaml` printed:

  ```bash
  git add .pre-commit-config.yaml
  git commit -m "🔖(pre-commit): Use bash-tools-framework ${NEXT} hooks" -m "<attribution>"
  git push origin "${DEFAULT_BRANCH}"
  git tag -f "${NEXT}"
  git push --force origin "refs/tags/${NEXT}"
  ```

  Then reiterate from step 4 (wait for the workflow run of the moved tag, check the release, re-check step 6). The loop
  normally ends after one extra pass; stop and ask the user if it iterates more than 3 times.

## 8. Report

Tell the user: the released version, the release URL, the commits created and pushed, the final tag commit sha, the
workflow run URL(s), and anything skipped or re-run.
