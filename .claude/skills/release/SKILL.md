---
name: release
description: >-
  Create a new GitHub release of this repository with gh: push the default branch, push the next tag, wait for the tag
  CI workflow to succeed, then create the release. Use when the user asks to "release", "create a release", "publish a
  new version" or "tag a new version". Optional argument: patch (default), minor, major or an explicit X.Y.Z version.
argument-hint: '[patch|minor|major|X.Y.Z]'
---

# Release

Requested version bump: `$ARGUMENTS` (empty means: ask the user, default patch).

Run every command from the repository root. Shell variables do not persist between Bash calls: re-define the values you
need (`DEFAULT_BRANCH`, `CURRENT`, `NEXT`) in each call, or substitute their literal values.

- Helper script: `.claude/skills/release/scripts/release-helper.sh`.
- Tags are lightweight `X.Y.Z` tags (no `v` prefix).
- CI workflow: `.github/workflows/main.yml`, triggered on tag push (override with `RELEASE_WORKFLOW=<file>`).
- This repository's own pre-commit hooks are declared as `repo: local` hooks in `.pre-commit-config.yaml`, so no
  pre-commit `rev` has to be updated when releasing.

## 1. Preconditions (stop and report if one fails)

```bash
gh auth status
DEFAULT_BRANCH="$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)"
git switch "${DEFAULT_BRANCH}"
git status --porcelain # must be empty: never release uncommitted work
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

## 2. Push the default branch

```bash
git push origin "${DEFAULT_BRANCH}"
```

Usually a no-op (already up to date). Pre-push hooks may run. Never use `--no-verify` and never force push the branch.

## 3. Create and push the tag

```bash
git tag "${NEXT}"
git push origin "refs/tags/${NEXT}"
```

## 4. Wait for the tag workflow

The CI (docker images, pre-commit, MegaLinter, bats matrix) takes a long time: run this with the Bash tool option
`run_in_background: true` and wait for the completion notification (do not poll its output):

```bash
.claude/skills/release/scripts/release-helper.sh wait-run "${NEXT}"
```

It finds the `main.yml` run for the tag at the tag commit (waiting up to 10 min for it to appear), watches it, and exits
non-zero with failing jobs and a log excerpt if it does not succeed.

On failure: do NOT create the release. Show the user the failing jobs and the log excerpt, and ask how to proceed:

- re-run the failed jobs: `gh run rerun <id> --failed`, then wait again (step 4);
- fix on the default branch, then move the tag onto the fix (`git tag -f "${NEXT}"` and
  `git push --force origin "refs/tags/${NEXT}"`, only with the user's approval) and wait again (step 4);
- abort. Never delete a pushed tag without the user's approval.

## 5. Create the release

Write release notes to a file in the scratchpad directory, in the style of the previous release
(`gh release view "${CURRENT}" --json body -q .body`): a short summary of the changes in
`git log --format='%s%n%b' "${CURRENT}..${NEXT}"` grouped by type (Features, Bug Fix, Documentation, Chore, ...), ending
with:

```text
**Full Changelog**: https://github.com/<owner>/<repo>/compare/<CURRENT>...<NEXT>
```

```bash
gh release create "${NEXT}" --verify-tag --title "${NEXT}" --notes-file "<scratchpad>/release-notes.md" --latest
```

## 6. Report

Tell the user: the released version, the release URL, the tag commit sha, the workflow run URL, and anything skipped or
re-run.
