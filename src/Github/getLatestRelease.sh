#!/usr/bin/env bash

# @description Retrieve the latest version number of a github release using Github API using retry
# repo arg with fchastanet/bash-tools value would match https://github.com/fchastanet/bash-tools
# @arg $1 repo:String repository in the format fchastanet/bash-tools
# @arg $2 resultRef:&String reference to a variable that will contain the result of the command
# @stdout log messages about retry
Github::getLatestRelease() {
  local repo="$1"
  # we need to pass the result through a reference instead of output directly
  # because retry can output too
  local -n resultRef=$2
  resultRef=""
  local resultFile
  resultFile="$(mktemp -p "${TMPDIR:-/tmp}" -t githubLatestRelease.XXXX)"
  # Get latest release from GitHub api
  if Retry::default curl \
    -o "${resultFile}" \
    --fail \
    --silent \
    "https://api.github.com/repos/${repo}/releases/latest"; then
    # shellcheck disable=SC2034
    resultRef="$(Version::githubApiExtractVersion <"${resultFile}")"
    return 0
  fi
  # display curl result in case of failure
  cat >&2 "${resultFile}"
  rm -f "${resultFile}"
}
