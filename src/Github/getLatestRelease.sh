#!/usr/bin/env bash

# @description Retrieve the latest version number of a github release using Github API using retry
# repo arg with fchastanet/bash-tools value would match https://github.com/fchastanet/bash-tools
# @arg $1 repo:String repository in the format fchastanet/bash-tools
# @arg $2 resultRef:&String reference to a variable that will contain the result of the command
# @stdout log messages about retry
# @env CURL_CONNECT_TIMEOUT number of seconds before giving up host connection
Github::getLatestRelease() {
  local repo="$1"
  # we need to pass the result through a reference instead of output directly
  # because retry can output too
  local -n resultRef=$2
  resultRef=""
  local resultFile
  resultFile="$(mktemp -p "${TMPDIR:-/tmp}" -t githubLatestRelease.XXXX)"
  local query="repos/${repo}/releases/latest"

  if command -v gh &>/dev/null && [[ -n "${GH_TOKEN}" ]]; then
    Log::displayDebug "Using gh to retrieve release versions list"
    Retry::parameterized "${RETRY_MAX_RETRY:-5}" \
      "${RETRY_DELAY_BETWEEN_RETRIES:-15}" \
      "Retrieving release versions list ..." \
      gh api "${query}" >"${resultFile}"
  else
    if command -v gh &>/dev/null && [[ "${GH_WARNING_DISPLAYED:-0}" = "0" ]]; then
      Log::displayWarning "GH_TOKEN is not set, cannot use gh, using curl to retrieve release versions list"
      GH_WARNING_DISPLAYED=1
    fi
    # Get latest release from GitHub api
    if Retry::default curl \
      -L \
      --connect-timeout "${CURL_CONNECT_TIMEOUT:-5}" \
      -o "${resultFile}" \
      --fail \
      --silent \
      "https://api.github.com/${query}"; then
      # shellcheck disable=SC2034
      resultRef="$(Version::githubApiExtractVersion <"${resultFile}")"
      return 0
    fi
  fi
  # display curl result in case of failure
  cat >&2 "${resultFile}"
  rm -f "${resultFile}"
  return 1
}
