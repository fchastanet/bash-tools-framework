#!/usr/bin/env bash

# @description Retrieve the latest version number of a web release
# @arg $1 releaseListUrl:String the url from which version list can be retrieved
# @stdout log messages about retry
# @env CURL_CONNECT_TIMEOUT number of seconds before giving up host connection
Web::getReleases() {
  local releaseListUrl="$1"
  # Get latest release from GitHub api
  Retry::default curl \
    -L \
    --connect-timeout "${CURL_CONNECT_TIMEOUT:-5}" \
    --fail \
    --silent \
    "${releaseListUrl}"
}
