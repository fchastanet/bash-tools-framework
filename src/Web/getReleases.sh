#!/usr/bin/env bash

# @description Retrieve the latest version number of a web release
# @arg $1 releaseListUrl:String the url from which version list can be retrieved
# @stdout log messages about retry
# @env CURL_CONNECT_TIMEOUT number of seconds before giving up host connection
Web::getReleases() {
  local releaseListUrl="$1"
  # Get latest release from GitHub api
  if command -v gh &>/dev/null && [[ -n "${GH_TOKEN}" ]]; then
    Log::displayDebug "Using gh to retrieve release versions list"
    Retry::parameterized "${RETRY_MAX_RETRY:-5}" \
      "${RETRY_DELAY_BETWEEN_RETRIES:-15}" \
      "Retrieving release versions list ..." \
      gh api "${releaseListUrl#https://github.com}"
  else
    if command -v gh &>/dev/null && [[ "${GH_WARNING_DISPLAYED:-0}" = "0" ]]; then
      Log::displayWarning "GH_TOKEN is not set, cannot use gh, using curl to retrieve release versions list"
      GH_WARNING_DISPLAYED=1
    fi
    Retry::parameterized "${RETRY_MAX_RETRY:-5}" \
      "${RETRY_DELAY_BETWEEN_RETRIES:-15}" \
      "Retrieving release versions list ..." \
      curl \
      -L \
      --connect-timeout "${CURL_CONNECT_TIMEOUT:-5}" \
      --fail \
      --silent \
      "${releaseListUrl}"
  fi
}
