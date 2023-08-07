#!/usr/bin/env bash

# download specified release software version from github
# @param {String} releaseUrl $1 eg: https://github.com/kubernetes-sigs/kind/releases/download/v1.0.0/kind-linux-amd64
# @return 1 on failure
# @output the path to the downloaded release
Github::downloadReleaseVersion() {
  local releaseUrl="$1"
  local newSoftwarePath

  # download specified version
  newSoftwarePath=$(mktemp -p "${TMPDIR:-/tmp}" -t github.newSoftware.XXXX)
  Retry::default curl \
    -L \
    -o "${newSoftwarePath}" \
    --fail \
    "${releaseUrl}" || return 1
  echo "${newSoftwarePath}"
}
