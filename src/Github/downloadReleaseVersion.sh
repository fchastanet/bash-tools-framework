#!/usr/bin/env bash

# @description download specified release software version from github
# @arg $1 releaseUrl:String eg: https://github.com/kubernetes-sigs/kind/releases/download/v1.0.0/kind-linux-amd64
# @exitcode 1 on failure
# @stdout the path to the downloaded release
# @env CURL_CONNECT_TIMEOUT number of seconds before giving up host connection
Github::downloadReleaseVersion() {
  local releaseUrl="$1"
  local newSoftwarePath

  # download specified version
  newSoftwarePath=$(mktemp -p "${TMPDIR:-/tmp}" -t github.newSoftware.XXXX)
  Retry::default curl \
    -L \
    --connect-timeout "${CURL_CONNECT_TIMEOUT:-5}" \
    -o "${newSoftwarePath}" \
    --fail \
    "${releaseUrl}" || return 1
  echo "${newSoftwarePath}"
}
