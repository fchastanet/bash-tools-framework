#!/usr/bin/env bash
# @description Helper used by the "release" Claude skill.
# Usage:
#   release-helper.sh current-version
#   release-helper.sh next-version <patch|minor|major|X.Y.Z>
#   release-helper.sh precommit-rev
#   release-helper.sh update-precommit <version>
#   release-helper.sh wait-run <tag> [sha]

set -o errexit -o nounset -o pipefail

SEMVER_REGEXP='^[0-9]+\.[0-9]+\.[0-9]+$'
PRE_COMMIT_FILE=".pre-commit-config.yaml"
WORKFLOW="${RELEASE_WORKFLOW:-main.yml}"

repoUrl() {
  gh repo view --json url -q .url
}

# latest released version (gh release), fallback to highest semver git tag
currentVersion() {
  local version
  version="$(gh release view --json tagName -q .tagName 2>/dev/null || true)"
  if [[ ! "${version}" =~ ${SEMVER_REGEXP} ]]; then
    version="$(git tag --list '[0-9]*.[0-9]*.[0-9]*' --sort=-v:refname | head -n 1)"
  fi
  if [[ ! "${version}" =~ ${SEMVER_REGEXP} ]]; then
    echo >&2 "ERROR: unable to find current version"
    return 1
  fi
  echo "${version}"
}

nextVersion() {
  local bump="${1:-patch}"
  local current major minor patch
  if [[ "${bump}" =~ ${SEMVER_REGEXP} ]]; then
    echo "${bump}"
    return 0
  fi
  current="$(currentVersion)"
  IFS=. read -r major minor patch <<<"${current}"
  case "${bump}" in
    patch) echo "${major}.${minor}.$((patch + 1))" ;;
    minor) echo "${major}.$((minor + 1)).0" ;;
    major) echo "$((major + 1)).0.0" ;;
    *)
      echo >&2 "ERROR: invalid bump '${bump}' (expected patch, minor, major or X.Y.Z)"
      return 1
      ;;
  esac
}

# print the rev of the pre-commit repo entry pointing to this repository
precommitRev() {
  local url
  url="$(repoUrl)"
  awk -v url="${url}" '
    $0 ~ "^[[:space:]]*-[[:space:]]*repo:[[:space:]]*" url "(\\.git)?[[:space:]]*$" { found = 1; next }
    found && /^[[:space:]]*rev:/ { sub(/^[[:space:]]*rev:[[:space:]]*/, ""); gsub(/["'\''[:space:]]/, ""); print; exit }
    found && /^[[:space:]]*-[[:space:]]*repo:/ { exit }
  ' "${PRE_COMMIT_FILE}"
}

# update rev of the self referencing repo entry
# prints the modified file (nothing if already up to date)
updatePrecommit() {
  local version="$1"
  local url tmpFile
  if [[ ! "${version}" =~ ${SEMVER_REGEXP} ]]; then
    echo >&2 "ERROR: invalid version '${version}'"
    return 1
  fi
  if [[ ! -f "${PRE_COMMIT_FILE}" ]]; then
    echo >&2 "ERROR: ${PRE_COMMIT_FILE} not found"
    return 1
  fi
  url="$(repoUrl)"
  tmpFile="$(mktemp)"
  awk -v url="${url}" -v version="${version}" '
    $0 ~ "^[[:space:]]*-[[:space:]]*repo:[[:space:]]*" url "(\\.git)?[[:space:]]*$" { found = 1; print; next }
    found && /^[[:space:]]*rev:/ { sub(/rev:.*/, "rev: " version); found = 0 }
    found && /^[[:space:]]*-[[:space:]]*repo:/ { found = 0 }
    { print }
  ' "${PRE_COMMIT_FILE}" >"${tmpFile}"
  if cmp -s "${tmpFile}" "${PRE_COMMIT_FILE}"; then
    rm -f "${tmpFile}"
  else
    cat "${tmpFile}" >"${PRE_COMMIT_FILE}"
    rm -f "${tmpFile}"
  fi
  git status --porcelain -- "${PRE_COMMIT_FILE}" | awk '{print $2}'
}

# wait for the workflow run triggered by the tag push and fail if it fails
waitRun() {
  local tag="$1"
  local sha="${2:-}"
  local runId="" i
  if [[ -z "${sha}" ]]; then
    sha="$(git rev-parse "${tag}^{commit}")"
  fi
  for ((i = 0; i < 60; i++)); do
    runId="$(gh run list --workflow "${WORKFLOW}" --branch "${tag}" --commit "${sha}" \
      --event push --limit 1 --json databaseId -q '.[0].databaseId // empty')"
    if [[ -n "${runId}" ]]; then
      break
    fi
    sleep 10
  done
  if [[ -z "${runId}" ]]; then
    echo >&2 "ERROR: no '${WORKFLOW}' run found for tag ${tag} (${sha}) after 10 minutes"
    return 1
  fi
  echo "Watching run ${runId}: $(gh run view "${runId}" --json url -q .url)"
  if gh run watch "${runId}" --exit-status --interval 30 >/dev/null; then
    echo "SUCCESS: run ${runId} for tag ${tag} succeeded"
  else
    echo >&2 "FAILURE: run ${runId} for tag ${tag} did not succeed"
    gh run view "${runId}" --json jobs \
      -q '.jobs[] | select(.conclusion != "success" and .conclusion != "skipped") | "\(.name): \(.conclusion)"' >&2 || true
    gh run view "${runId}" --log-failed 2>/dev/null | tail -n 80 >&2 || true
    return 1
  fi
}

command="${1:-}"
shift || true
case "${command}" in
  current-version) currentVersion ;;
  next-version) nextVersion "$@" ;;
  precommit-rev) precommitRev ;;
  update-precommit) updatePrecommit "$@" ;;
  wait-run) waitRun "$@" ;;
  *)
    echo >&2 "Usage: $0 <current-version|next-version|precommit-rev|update-precommit|wait-run> [args]"
    exit 1
    ;;
esac
